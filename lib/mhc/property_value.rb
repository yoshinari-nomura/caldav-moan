module Mhc
  module PropertyValue
    class Base
      def self.parse(string)
        return self.new.parse(string)
      end

      def parse(string)
        @value = string
      end

      def to_mhc_string
        return @value.to_s
      end
    end
  end

  subdir = File.dirname(__FILE__) + "/property_value/"
  require subdir + "list.rb"
  require subdir + "date.rb"
  require subdir + "date_list.rb"
  require subdir + "period.rb"
  require subdir + "recurrence_condition.rb"
  require subdir + "time.rb"
end
