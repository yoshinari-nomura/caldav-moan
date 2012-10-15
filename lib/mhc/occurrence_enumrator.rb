# -*- coding: utf-8 -*-

module Mhc
  class OccurrenceEnumerator
    class Base
      def set_start(date)
        @start_date = date
        return self
      end
    end

    class Merger < Base
      def initialize
        @enumerators = []
      end

      def merge(enumrator)
        @enumerators << enumerator
      end

      def each_ocurrence(from, to)
        self.set_start(from)
        while ocurrence = self.shift && occurrence <= to
          yield(ocurrence)
        end
      end

      protected :set_start

      def set_start(date)
        @enumerators.each {|e| e.set_start(date) }
        return self
      end

      def reset_index
        @index = 0
      end

      def shift
        top = @enumerators.min_by {|e| e.first }
        return top.shift
      end
    end

    class ByDateList < Base
      def initialize(dates)
        @dates = dates.sort
      end

      def ocurrence
        return @dates[@index]
      end

      def shift
        top = self.occurrence
        @index += 1
        return occurrence
      end
    end

    class ByDay < Base
      def initialize(month, nth, week)
        @month, @nth, @wday = month, nth, week
      end

      private

      def occurrence
        return (date + 1).nearest_date_byday(@month, @nth, @wday)
      end
    end

    class ByMonthDay < Base
      def initialize(month, mday)
        @month, @mday = month, mday
      end

      private
      def include?(date)
        return date.month == @month && date.mday == @mday
      end

      def next_occurrence(date)
        return date.nearest_date_bymonthday(@month, @mday)
      end

    end
  end # class OccurrenceEnumerator
end # module Mhc
