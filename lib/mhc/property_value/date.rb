# -*- coding: utf-8 -*-

require "date"

module Mhc
  module PropertyValue
    class Date < ::Date

      DAYS_OF_MONTH = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

      def to_time(time = nil)
        if time
          return ::Time.local(year, month, mday, time.hour, time.minute)
        else
          return ::Time.local(year, month, mday, 0, 0)
        end
      end

      def to_mhc_string
        return self.strftime("%Y%m%d")
      end

      def last_week_of_month?
        return mday > days_of_month - 7
      end

      def week_number_of_month
        return (mday - 1) / 7
      end

      def days_of_month
        return DAYS_OF_MONTH[month] + (month == 2 && leap? ? 1 : 0)
      end

      def first_day_of_month
        return new(year, month, 1)
      end

      def last_day_of_month
        return new(year, month, days_of_month)
      end

      def each_day_in_month
        for d in (1 .. days_of_month)
          yield new(year, month, d)
        end
      end

      def today?
        return self.class.today == self
      end

    end # class Date
  end # module PropertyValue
end # module Mhc
