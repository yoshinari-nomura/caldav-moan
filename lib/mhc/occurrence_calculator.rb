# -*- coding: utf-8 -*-
module Mhc
  class OccurrenceCalculator

    VERY_OLD_DAY = Mhc::PropertyValue::Date.new(2000, 1, 1)

    def initialize(dates, time_range, exceptions,
                   recurrence_condition, duration)
      @dates                = dates
      @time_range           = time_range
      @exceptions           = exceptions
      @recurrence_condition = recurrence_condition
      @duration             = duration

      @calculators = nil
      build_children
    end

    def first_occurence_date
      date = (@duration.first || VERY_OLD_DAY) - 1
      return @calculators.map {|calc| calc.next_occurence(date) }.min
    end

    def occurs_on?(date)
      return !excaptional_date?(date) && include?(date)
    end

    ################################################################
    private

    def include?(date)
      return @calculators.any? {|calc| calc.include?(date) }
    end

    def exceptional_date?(date)
      return !@duration.include?(date) || @exceptions.include?(date)
    end
  end
end
