module Mhc
  module IcalendarSupport
    # FREQ=YEARLY
    def rrule_freq
      if cond_mon.length > 0
        freq = "YEARLY"
      elsif cond_num.length > 0
        freq = "MONTHLY" # monthly by date: 16
      elsif cond_wek.length > 0 && cond_ord.length > 0
        freq = "MONTHLY" # monthly by day:  1st Sun
      elsif cond_wek.length > 0
        freq = "WEEKLY"  # weekly: Sun
      else
        freq = nil
      end
      return freq
    end

    # INTERVAL=1
    def rrule_interval
      return 1
    end

    # BYDAY=1MO,2WE
    def rrule_byday
      wdic = Hash[*%w(Sun SU Mon MO Tue TU Wed WE Thu TH Fri FR Sat SA)]
      odic = Hash[*%w(1st 1 2nd 2 3rd 3 4th 4 5th 5 Last -1)]
      return nil if cond_wek.empty?
      weeks  = cond_wek.map{|w| wdic[w]}
      return weeks.join(',') if cond_ord.empty?
      orders = cond_ord.map{|o| odic[o]}
      return weeks.map{|w| orders.map{|o| o + w }}.join(',')
    end

    # BYMONTHDAY=1,2,31
    def rrule_bymonthday
      return nil if cond_num.empty?
      return cond_num.map{|n| n.to_i}.join(',')
    end

    # BYMONTH=1,2,3
    def rrule_bymonth
      return nil if cond_mon.empty?
      return cond_mon.map{|m|
        ("JanFebMarAprMayJunJulAugSepOctNovDec".index(m)) / 3 + 1
      }.join(',')
    end
  end # module IcalendarSupport
end # module Mhc
