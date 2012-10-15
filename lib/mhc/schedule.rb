# -*- coding: utf-8 -*-

### schedule.rb
##
## Author:  Yoshinari Nomura <nom@quickhack.net>
##
## Created: 1999/07/16
## Revised: $Date: 2008-10-08 03:22:37 $
##

module Mhc
  #
  # X-SC-Subject: 
  # X-SC-Location:
  # X-SC-Day:
  # X-SC-Time:
  # X-SC-Category:
  # X-SC-Priority:
  # X-SC-Cond:
  # X-SC-Duration:
  # X-SC-Alarm:
  # X-SC-Record-Id:
  #
  class Schedule
    ################################################################
    ## initializers

    def initialize
      clear
    end

    def self.parse(string)
      return new.parse(string)
    end

    def parse_file(path, lazy = true)
      clear
      header, body = nil, nil

      File.open(path, "r") do |file|
        header = file.gets("\n\n")
        body   = file.gets(nil) unless lazy
      end

      @path = path if lazy
      parse_header(header)
      return self
    end

    def parse(string)
      clear
      header, body = string.split(/\n\n/, 2)

      parse_header(header)
      self.description = body
      return self
    end

    ################################################################
    ## access methods to each property.

    ## alarm
    def alarm
      return @alarm ||= Mhc::PropertyValue::Period.new
    end

    def alarm=(string)
      return @alarm = alarm.parse(string)
    end

    ## category
    def categories
      return @categories ||= 
        Mhc::PropertyValue::List.new(Mhc::PropertyValue::Text)
    end

    def categories=(string)
      return @categories = categories.parse(string)
    end

    ## description
    def description
      unless @description
        @description = Mhc::PropertyValue::Text.new

        if lazy? && File.file?(@path)
          File.open(@path, "r") do |file|
            file.gets("\n\n") # discard header.
            @description.parse(file.gets(nil))
          end
        end
      end
      return @description
    end

    def description=(string)
      return @description = description.parse(string)
    end

    ## location
    def location
      return @location ||= Mhc::PropertyValue::Text.new
    end

    def location=(string)
      return @location = location.parse(string)
    end

    ## priority
    def priority
      return @priority ||= Mhc::PropertyValue::Integer.new
    end

    def priority=(string)
      return @priority = priority.parse(string)
    end

    ## record-id
    def record_id
      return @record_id ||= Mhc::PropertyValue::Text.new
    end

    def record_id=(string)
      return @record_id = record_id.parse(string)
    end

    def uid
      return @record_id.to_s.gsub(/[<>]/, "")
    end

    ## subject
    def subject
      return @subject ||= Mhc::PropertyValue::Text.new
    end

    def subject=(string)
      return @subject = subject.parse(string)
    end

    ## date list
    def dates
      return @dates ||=
        Mhc::PropertyValue::List.new(Mhc::PropertyValue::Date)
    end

    def dates=(string)
      return @dates = dates.parse(string)
    end

    def exceptions
      return @exceptions ||=
        Mhc::PropertyValue::List.new(Mhc::PropertyValue::Date, ?!)
    end

    def exceptions=(string)
      return @exceptions = exceptions.parse(string)
    end

    ## time
    def time_range
      return @time_range ||=
        Mhc::PropertyValue::Range.new(Mhc::PropertyValue::Time)
    end

    def time_range=(string)
      return @time_range =  time_range.parse(string)
    end

    ## duration
    def duration
      return @date_range ||=
        Mhc::PropertyValue::Range.new(Mhc::PropertyValue::Date)
    end

    def duration=(string)
      return @duration = duration.parse(string)
    end

    ## recurrence condition
    def recurrence_condition
      return @cond ||= Mhc::PropertyValue::RecurrenceCondition.new
    end

    def recurrence_condition=(string)
      return @cond = recurrence_condition.parse(string)
    end

    ################################################################
    ## occurrence_caluculator

    def occurrence_caluculator
      @oc ||= Mhc::OccurrenceCalculator.new(dates, 
                                            time_range,
                                            exceptions,
                                            recurrence_condition, 
                                            duration)
      return @oc
    end

    def dtstart
      @oc.dtstart
    end

    def dtend
      @oc.dtend
    end

    ################################################################
    ## predicates

    def todo?
      return categories.include?("Todo")
    end

    ################################################################
    ### dump

    def dump
      non_xsc_header = @non_xsc_header.to_s.sub(/\n+\z/n, "")
      non_xsc_header += "\n" if header != ""

      body = description.to_s
      body += "\n" if body != "" && body !~ /\n\z/n

      return dump_header + non_xsc_header + "\n" + body
    end

    def dump_header
      return "X-SC-Subject: #{subject.to_mhc_string}\n"      +
        "X-SC-Location: #{location.to_mhc_string}\n"         +
        "X-SC-Day: #{dates.to_mhc_string} #{exceptions.to_mhc_string}\n" +
        "X-SC-Time: #{time_range.to_mhc_string}\n"           +
        "X-SC-Category: #{categories.to_mhc_string}\n"       +
        "X-SC-Priority: #{priority.to_mhc_string}\n"         +
        "X-SC-Cond: #{recurrence_condition.to_mhc_string}\n" +
        "X-SC-Duration: #{duration.to_mhc_string}\n"         +
        "X-SC-Alarm: #{alarm.to_mhc_string}\n"               +
        "X-SC-Record-Id: #{record_id.to_mhc_string}\n"
    end

    ################################################################
    private

    def lazy?
      return !@path.nil?
    end

    def clear
      @alarm, @categories, @description, @location = [nil]*4
      @priority, @record_id, @subject = [nil]*3
      @dates, @exceptions, @time_range, @duration, @cond, @oc = [nil]*6
      @non_xsc_header, @path = [nil]*2
      return self
    end

    def parse_header(string)
      xsc, @non_xsc_header = separate_header(string)
      parse_xsc_header(xsc)
      return self
    end
    
    def parse_xsc_header(hash)
      hash.each do |key, val|
        case key
        when "day"       ; self.dates      = val ; self.exceptions = val
        when "subject"   ; self.subject    = val
        when "location"  ; self.location   = val
        when "time"      ; self.time_range = val
        when "duration"  ; self.duration   = val
        when "category"  ; self.categories = val
        when "cond"      ; self.condition  = val
        when "alarm"     ; self.alarm      = val
        when "record-id" ; self.record_id  = val
        when "priority"  ; self.priority   = val
        else
          raise NotImplementedError, "X-SC-#{key.upcase}"
        end
      end
      return self
    end

    ## return: X-SC-* headers as a hash and
    ##         non-X-SC-* headers as one string.
    def separate_header(header)
      xsc, non_xsc, xsc_key = {}, "", nil

      header.split("\n").each do |line|
        if line =~ /^X-SC-([^:]+):(.*)/ni
          xsc_key = $1.downcase
          xsc[xsc_key] = $2.to_s.strip

        elsif line =~ /^\s/ && xsc_key
          xsc[xsc_key] += " " + line

        else
          xsc_key = nil
          non_xsc += line + "\n"
        end
      end
      return [xsc, non_xsc]
    end

  end # class ScheduleItem
end # module Mhc


### Copyright Notice:

## Copyright (C) 1999, 2000 Yoshinari Nomura. All rights reserved.
## Copyright (C) 2000 MHC developing team. All rights reserved.

## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions
## are met:
## 
## 1. Redistributions of source code must retain the above copyright
##    notice, this list of conditions and the following disclaimer.
## 2. Redistributions in binary form must reproduce the above copyright
##    notice, this list of conditions and the following disclaimer in the
##    documentation and/or other materials provided with the distribution.
## 3. Neither the name of the team nor the names of its contributors
##    may be used to endorse or promote products derived from this software
##    without specific prior written permission.
## 
## THIS SOFTWARE IS PROVIDED BY THE TEAM AND CONTRIBUTORS ``AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
## LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
## FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
## THE TEAM OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
## INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
## (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
## HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
## STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
## OF THE POSSIBILITY OF SUCH DAMAGE.

### schedule.rb ends here
