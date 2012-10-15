################################################################
## 4.3 Property Value Data Types
################################################################
module Mhc
  module ICalendar
    module PropertyValue
      class Base
      end

      # 4.3.1 Binary
      #
      # Description: all inline binary data MUST first be character
      # encoded using the "BASE64" encoding method defined in [RFC 2045].
      # Property values with this value type MUST also include the inline
      # encoding parameter sequence of ";ENCODING=BASE64".
      #
      class Binary < Base
      end

      # 4.3.2 Boolean
      #
      # Description: TRUE or FALSE (case insensitive).
      #
      class Boolean < Base
      end

      # 4.3.3 Calendar User Address
      #
      # Description: URI. when used to address an Internet email transport
      # address for a calendar user, the value MUST be a MAILTO URI.
      #
      # Example:
      #   ATTENDEE:MAILTO:jane_doe@host.com
      #
      class CalAddress < Base
      end

      # 4.3.4 Date
      #
      # Description: YYYYMMDD
      # 
      class Date < Base
      end

      # 4.3.5 Date-Time
      #
      # Description: The "DATE-TIME" data type expresses time values in
      # three forms:
      #
      # FORM #1: DATE WITH LOCAL TIME (floating time)
      #   DTSTART:19980118T230000
      #
      # FORM #2: DATE WITH UTC TIME
      #   DTSTART:19980119T070000Z
      #
      # FORM #3: DATE WITH LOCAL TIME AND TIME ZONE REFERENCE
      #   DTSTART;TZID=US-Eastern:19980119T020000
      #
      class DateTime < Base
      end

      # 4.3.6 Duration
      # 
      # Description: [ISO 8601] basic format for the duration of time. The
      # format can represent durations in terms of weeks, days, hours,
      # minutes, and seconds.
      #
      #   dur-value  = (["+"] / "-") "P" (dur-date / dur-time / dur-week)
      #   dur-date   = dur-day [dur-time]
      #   dur-time   = "T" (dur-hour / dur-minute / dur-second)
      #   dur-week   = 1*DIGIT "W"
      #   dur-hour   = 1*DIGIT "H" [dur-minute]
      #   dur-minute = 1*DIGIT "M" [dur-second]
      #   dur-second = 1*DIGIT "S"
      #   dur-day    = 1*DIGIT "D"
      #
      class Duration < Base
      end

      # 4.3.7 Float
      #
      # Description:
      #   float      = (["+"] / "-") 1*DIGIT ["." 1*DIGIT]
      #
      class Float < Base
      end

      # 4.3.8 Integer
      #
      # Description:
      #  integer    = (["+"] / "-") 1*DIGIT
      #
      class Integer < Base
      end

      # 4.3.9 Period of Time
      #
      # Description:
      #   period-explicit = date-time "/" date-time
      #      ; The start MUST be before the end.
      #   period-start = date-time "/" dur-value
      #      ; time consisting of a start and positive duration of time.
      #
      # Example:
      #   19970101T180000Z/19970102T070000Z
      #   19970101T180000Z/PT5H30M
      #
      class Period < Base
      end

      # 4.3.10 Recurrence Rule
      #
      class Recur < Base
      end

      # 4.3.11 Text
      #
      #  text       = *(TSAFE-CHAR / ":" / DQUOTE / ESCAPED-CHAR)
      #  ; Folded according to description above
      #
      #  ESCAPED-CHAR = "\\" / "\;" / "\," / "\N" / "\n")
      #  ; \\ encodes \, \N or \n encodes newline
      #  ; \; encodes ;, \, encodes ,
      #
      #  TSAFE-CHAR = %x20-21 / %x23-2B / %x2D-39 / %x3C-5B
      #               %x5D-7E / NON-US-ASCII
      #  ; Any character except CTLs not needed by the current
      #  ; character set, DQUOTE, ";", ":", "\", ","
      #
      class Text < Base
      end

      # 4.3.12 Time
      #
      # Example:
      #   X-TIMEOFDAY:083000
      #   X-TIMEOFDAY:133000Z
      #   X-TIMEOFDAY;TZID=US-Eastern:083000
      #
      class Time < Base
        def self.parse(str)
          if str =~ /^(\d{2})(\d{2})(\d{2})(Z)?$/
            insec = ($1.to_i) * 3600 + ($2.to_i) * 60 + ($3.to_i)
            timezone = $4 ? 'UTC' : nil
            return self.new(sec, timezone)
          else
            raise "Time format Error."
          end
        end

        def initialize(sec, timezone = 'LOCAL')
          @sec, @timezone = sec, timezone
        end
      end

      # 4.3.13 URI
      #
      class Uri < Base
      end

      # 4.3.14 UTC Offset
      #
      # Description:
      #  time-numzone       = ("+" / "-") time-hour time-minute [time-second]
      # 
      class UtcOffset < Base
      end

    end # module PropertyValue
  end # module ICalendar
end # module Mhc
