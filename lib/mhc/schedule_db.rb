# Item have to have these interface:
#  uid:      String: unique id
#  duration: DateRange
#  etag:     Etag
#  min_bondary:
#  max_bondary:
# ID -> ScheduleItem
# Slot -> [ScheduleItem]
# ScheduleItem -> ETag
# rec_id
# first_occurrence_date
# last_occurrence_date

# find_by_uid(uid)
# find_in(from, to, category_expression)
# add, del
# signal_connect
# signal_disconnect
#
# db.holiday?(date)
# db.each_schedule(from, to) do |sch|

# article have to resond to
#  :first_occurence_date
#  :last_occurence_date
#  :occurs_on?(date)
#  :categories

module Mhc
  class ScheduleDB
    def initialize(basedir = DEF_BASEDIR, *rcfiles)
      @db        = {}
      @mtime     = {}
      @basedir   = basedir
      @rcfiles   = rcfiles.length == 0 ? [DEF_RCFILE] : rcfiles
      @slots     = @rcfiles + [@basedir + '/intersect']
      @alarm     = nil
      @log       = Log.new(@basedir + '/.mhc-db-log')
    end

    def delete(schedule)
      @datastore.delete(schedule.uid)
      @log.add_entry(MhcLogEntry.new('D', ::Time.now, 
                                     sch.rec_id, sch.path, sch.subject))
      return self
    end

    def store(schedule)
      slot = schedule_to_slot(schedule)
      @datastore.store(schedule.uid, slot, schedule.dump)
      @log.add_entry(MhcLogEntry.new('M', ::Time.now, 
                                     sch.rec_id, sch.path, sch.subject))
      return self
    end

    def each_date(from, to)
      hash = {}
      search(from, to).each do |date, schedules|
        schedules.each do |schedule|
          yield(schedule) if !hash[schedule]
          hash[schedule] = true
        end
      end
    end

    def search(from, to, category = nil, do_update = true)
      ret = []
      for date in from .. to
        ret << [date, search1(date, category, do_update)]
      end
      return ret
    end

    def holiday?(date)
      return !search1(date, 'Holiday').empty?
    end

    def search1(d, category = nil, do_update = true)
      mon, wek, ord, day, date = d.m_s, d.w_s, d.o_s, d.d_s, d
      all, last = 'all', 'Last'
      ret = []
      category_ary, category_is_invert = nil, false

      if category
        if category =~ /!/
          category_is_invert = true
          category = category.delete('!')
        else
          category_is_invert = false
        end
        category_ary = category.split.collect{|x| x.capitalize}
      end

      search_key = [date, mon+ord+wek, mon+all+wek, all+ord+wek,
                    all+all+wek, mon+day, all+day]
      search_key << mon+last+wek << all+last+wek if d.o_last?

      update(d) if do_update
      date_to_slots(d).each{|slot|
        search_key.each{|key|
          if @db[slot][key].is_a?(Array)
            @db[slot][key].each{|item|
              if (item.in_duration?(date)) && !(item.in_exception?(date)) &&
                  (!category ||
                   (!category_is_invert &&  item.in_category?(category_ary)) ||
                   ( category_is_invert && !item.in_category?(category_ary)))
                ret << item
              end
            }
          end
        }
      }
      return ret.sort{|a,b| a.time_b.to_s <=> b.time_b.to_s}.uniq
    end

    ################################################################
    private

    def date_to_slot(date)
      return date.strftime("%Y/%d")
    end

    def date_to_slots(date)
      mon, wek, ord, day = 
        date.month, date.wday, date.week_number_of_month, date.mday

      all, last = 'all', 'Last'

      keys = [date, mon+ord+wek, mon+all+wek, all+ord+wek,
                    all+all+wek, mon+day, all+day]
      keys << mon+last+wek << all+last+wek if d.o_last?

      return search_key
    end

    def schedule_to_search_keys(schedule)
    end

    def schedule_to_slot(date)
      if sch.occur_inter_month? or sch.todo?
        return 'intersect'
      else
        return date_to_slot(sch.first_occurrence_date)
      end
    end

  end # class ScheduleDB
end # module Mhc
