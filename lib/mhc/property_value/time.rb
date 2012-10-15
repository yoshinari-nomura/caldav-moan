require File.dirname(__FILE__) + '/../utils'

module Mhc
  class Time
    include Comparable

    def initialize(hour = 0, minute = 0)
      if h.is_a?(String) && hour =~ /^(\d+):(\d+)$/
        @sec = ($1.to_i) * 3600 + ($2.to_i) * 60
      else
        @sec = (hour.to_i)  * 3600 + (minute.to_i)  * 60
      end
    end

    def days;     @sec          / 86400 ;end
    def hour;    (@sec % 86400) / 3600  ;end
    def minute;  (@sec % 3600)  / 60    ;end

    def <=>(o)
      if o.kind_of?(Mhc::Time)
        return @sec <=> o.to_i
      else
        return nil
      end
    end

    def to_s
      return format("%02d:%02d", hour, minute)
    end

    def to_i
      return @sec
    end

    def to_a
      return [hour, minute]
    end

    def to_utc(date)
      return to_t(date).utc
    end

    def to_t(date = Mhc::Date.new(1970, 1, 2))
      date = date.succ(day)
      ::Time.local(date.y, date.m, date.d, hour, minute)
    end
  end # class Time
end # module Mhc
