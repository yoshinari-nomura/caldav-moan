#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/lib/mhc'
require "yaml"
require "uri"

################################################################
#
# Our Sync mechanism is very simple, because
# we can assume every article is independent
# with eath other. It will work well with
# iCalendar basis articles.
#
# We simply follow the rule on the table below:
#
#                  Local
#     +---+---------------------------------+
#   R |   | D          M          N         |
#   e +---+---------------------------------+
#   m | D | -          CONFLICT   DELETE L  |
#   o | M | CONFLICT   CONFLICT   PUT R->L  |
#   t | N | DELETE R   PUT L->R   -         |
#   e +---+---------------------------------+
#
#   (D,M,N) indicates some status change on each article
#   after the last sync:
#
#       D ... Deleted
#       M ... Modified or Created
#       N ... No Cahnge or No Entry
#
# Before applying the rule to our repository,
# we have to set the marks (D,M,N) to all articles
# in each side.
#
# We assume a CalDAV server as a remote side.
# CalDAV has no ability to provide such information.
# It only provides ETag mechanism, which is defined
# in HTTP protocol (see rfc2616).
#
# So, we have to maintain a cache (replica) on local and 
# manage difference between the cache and the remote,
# using ETag (kind of dirty flag) information:
#
# (1) get uid-etag list via PROPFIND (WebDav) method
#
#     make up a set: R_SET = [(r_uid, r_etag)..]
#       r_uid:  unique id of a remote article.
#       r_etag: corresponding etag of r_uid.
#
# (2) get uid-etag list via local cache.
#
#     make up a set: L_SET = [(l_uid, l_etag)..]
#
# (3) for each uid: [uid| (uid, etag) <- L_SET + R_SET]
#
#     (A) if (uid, _) is missed in L_SET
#           -> SET_MARK(uid, M)
#
#     (B) if (uid, _) is missed in R_SET
#           -> SET_MARK(uid, D)
#
#     (C) if (uid, _) exists in both R_SET and L_SET
#           if l_etag != r_etag
#             -> SET_MARK(uid, M)
#           if l_etag == r_etag
#             -> SET_MARK(uid, N)
#

################################################################
### Some Utils

def pp_element(element, name)
  puts "#{name}: #{element.elements[name].text}"
end

def show_calendar_property(xmldoc)
  pe = xmldoc
  puts "---------------------------------------"
  pp_element pe, "C:calendar-description"
  pp_element pe, "A:calendar-color"
  pp_element pe, "D:displayname"
  pp_element pe, "CS:getctag"
  puts "---------------------------------------"
end

################################################################
## Sync Strategy and Driver

module Sync
  module Strategy
    class Mirror
      def initialize(origin_db, local_db)
        @origin_db, @local_db = origin_db, local_db
      end

      def whatnow(uid)
        l_info = @local_db.find(uid)
        r_info = @origin_db.find(uid)

        if !l_info
          return :fetch_origin
        elsif !r_info
          return :remove_local
        elsif l_info.etag == r_info.etag
          return :do_nothing
        else
          return :fetch_origin
        end
      end
    end # class Mirror
  end # module Strategy
end # module Sync

module Sync
  class Driver
    def initialize(origin_db, local_db, strategy = :mirror)
      @origin_db, @local_db = origin_db, local_db

      case strategy
      when :mirror
        @strategy = Strategy::Mirror.new(origin_db, local_db)
      else
        raise NotImplementedError
      end
    end

    def foreach
      all_uid = (@origin_db.uid_list + @local_db.uid_list).sort.uniq
      all_uid.each do |uid|
        yield(uid, @strategy.whatnow(uid))
      end
    end
  end
end

################################################################
## SyncInfo

class SyncInfoDB

  def initialize(propfind_xml = nil)
    @db = {}
    add_from_xml(propfind_xml) if propfind_xml
  end

  def find(uid)
    return @db[uid]
  end

  def uid_list
    return @db.keys
  end

  def update(info)
    @db[info.uid] = info
  end

  def add_from_xml(propfind_xml)
    xmldoc = REXML::Document.new(propfind_xml)
    xmldoc.elements.each("D:multistatus/D:response") do |res|
      if res.elements["D:propstat/D:prop/D:resourcetype/D:collection"]
        show_calendar_property(res.elements["D:propstat/D:prop"])
      else
        update(SyncInfo.new_from_xml(res))
      end
    end
    return self
  end
end

class SyncInfo
  attr_accessor :uid, :etag, :href, :content_type, :status, :local_status, :ics

  def self.new_from_xml(xmldoc)
    info = self.new

    # print xmldoc.text

    href, status, content_type, etag, ics = 
      %w(D:href
         D:propstat/D:status
         D:propstat/D:prop/D:getcontenttype
         D:propstat/D:prop/D:getetag
         D:propstat/D:prop/C:calendar-data
      ).map{|e| xmldoc.elements[e].text rescue nil}

    info.href = URI.unescape(href)
    info.uid = info.href
    info.status = status
    info.content_type = content_type
    info.etag = unquote_string(etag)
    info.ics = ics
    return info
  end

  private_class_method

  def self.unquote_string(str)
    return str.gsub('"', "")
  end

end # class SyncInfo

################################################################
## load config 

calendar_name = ARGV[0] || "default" # XXX

config_file = File.expand_path("~/.mhc/config.yml")

config = YAML.load_file(config_file)
caldav_conf = config["CALDAV"][calendar_name]

user        = caldav_conf["USER"]
password    = caldav_conf["PASSWORD"]
url         = caldav_conf["URL"]
local_top_directory = caldav_conf["LOCAL_TOP"]
top_directory         = URI.parse(url).path

################################################################
### main

print "connecting to #{url} ...\n"

origin_dav = Mhc::CalDav::Client.new(url)
local_dav  = Mhc::CalDav::Cache.new(url)

origin_dav.set_basic_auth(user, password)
local_dav.set_top_directory(local_top_directory)

origin_proplist = origin_dav.propfind(top_directory, 1)
local_proplist = local_dav.propfind(top_directory, 1)

origin_sync_db = SyncInfoDB.new(origin_proplist.body)
local_sync_db = SyncInfoDB.new((local_proplist rescue nil))

driver = Sync::Driver.new(origin_sync_db, local_sync_db, :mirror)

fetch_queue, delete_queue = [], []

driver.foreach do |path, whatnow|
  case whatnow
  when :fetch_origin
    # print "FETCH: #{path}\n"
    fetch_queue << path
    # local_dav.put(origin_dav.get(path).body, path)
  when :remove_local
    # print "DELETE: #{path}\n"
    delete_queue << path
  else
    # :do_nothing
  end
end

unless delete_queue.empty?
  print "delete #{delete_queue.length} article(s).\n"
  delete_queue.each do |ics|
    local_dav.delete(ics)
  end
end

unless fetch_queue.empty?
  print "fetch #{fetch_queue.length} article(s).\n"
  db = origin_dav.report_calendar_multiget(fetch_queue, top_directory)
  db.uid_list.each do |uid|
    local_dav.put(db.find(uid).ics, uid)
  end
end

local_dav.set_propfind_cache(top_directory, origin_proplist.body)
