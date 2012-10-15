module Mhc
  module ICalendar
    class ContentLine
      # contentline   = name *(";" param ) ":" value CRLF
      # param         = param-name "=" param-value
      #                 *("," param-value)
      # param-value   = paramtext / quoted-string
      # paramtext     = *SAFE-CHAR
      # quoted-string = DQUOTE *QSAFE-CHAR DQUOTE
      #
      # QSAFE-CHAR    = WSP / %x21 / %x23-7E / NON-US-ASCII
      #                 ; Any character except CTLs and DQUOTE
      #
      # SAFE-CHAR     = WSP / %x21 / %x23-2B / %x2D-39 / %x3C-7E / NON-US-ASCII
      #                 ; Any character except CTLs, DQUOTE, ";", ":", ","
      #
      NAME          = '[a-zA-Z\d-]+'
      PARAM_NAME    = '[a-zA-Z\d-]+'
      QUOTED_STRING = '"[^"]*"'       # xxx
      PARAMTEXT     = '[^";:,]+'      # xxx

      PARAM_VALUE = "(?:#{PARAMTEXT}|#{QUOTED_STRING})"
      PARAM       = "(#{PARAM_NAME})=(#{PARAM_VALUE}(?:,#{PARAM_VALUE})*)"
      VALUE       = ".*"
      CONTENTLINE = "(#{NAME})((?:;#{PARAM})*):(#{VALUE})"


      def self.parse(string)
        string = string.unfold
        string.chomp!
        params = {}

        if string =~ /^#{CONTENTLINE}$/
          name, param_list, value = $1, $2, $+  # $+ : last paren
          $log.print "found property #{name}\n"
          if param_list
            param_list.scan(/#{PARAM}/) do
              param_name, param_value_list = $1, $2
              params[param_name] = []

              param_value_list.scan(/#{PARAM_VALUE}/) do
                params[param_name] <<  $&.unquote # param_value
              end
            end
          end
          return new(name, params, value)
        end
        raise "format error : #{string}."
      end

      attr_reader :name, :params, :value

      def initialize(name, params, value)
        @name, @params, @value = name, params, value
      end
    end # class ContentLine
  end # module ICalendar
end # module Mhc
