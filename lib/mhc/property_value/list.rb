module Mhc
  module PropertyValue
    class List < Base
      ITEM_SEPARATOR = " "

      def initialize(item_class, prefix = nil)
        @list = []
        @prefix = prefix
        @item_class = item_class
      end

      def parse(string)
        string.split(ITEM_SEPARATOR).each do |item|
          next if prefix && item[0] != prefix
          @list << @item_class.parse(item)
        end
        return self
      end

      def include?(item)
        return @list.include?(item)
      end

      def to_mhc_string
        @list.map{|item| @prefix.to_s + item.to_mhc_string}.join(ITEM_SEPARATOR)
      end

    end # class List
  end # module PropertyValue
end # module Mhc
