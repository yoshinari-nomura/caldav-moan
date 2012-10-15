module Mhc
  module PropertyValue
    #
    # DateList represents the value of an X-SC-Date.
    # Since X-SC-Date has exception dates and occurrence dates, 
    # it has a pair of DateList objects.
    #
    class DateList < List

      def initialize(prefix = nil)
        super(Mhc::Date, prefix)
      end

      def occurrence_caluculator
        return Mhc::OccurrenceCalculator::DateList.new(self)
      end

    end # class DateList
  end # module PropertyValue
end # module Mhc
