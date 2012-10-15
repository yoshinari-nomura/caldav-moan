module Mhc
  module ICalendar
    module Component
      class Base
        class << self
          def has_component?(name)
            return @component_list[name] rescue false
          end

          def has_property?(name)
            return @property_list[name] rescue false
          end

          private

          def add_component(name)
            @component_list ||= {}
            @component_list[name] = true
          end

          def add_property(name)
            @property_list ||= {}
            @property_list[name] = true
          end

          def mandatory_multi_component(state_num, *name)
            name.map{|n| add_component(n) }
          end

          def optional_multi_component(state_num, *name)
            name.map{|n| add_component(n) }
          end

          def mandatory_singleton_property(state_num, *name)
            name.map{|n| add_property(n) }
          end

          def optional_singleton_property(state_num, *name)
            name.map{|n| add_property(n) }
          end

          def optional_multi_property(state_num, *name)
            name.map{|n| add_property(n) }
          end

        end # class methods

        def has_component?(name)
          ret = self.class.has_component?(name)
          $log.print("has_component?(#{name}) => #{ret}")
          return ret
        end

        def initialize(name = nil)
          @parser_state = 0
          @name = name
          @prop = []
          @comp = []
        end

        def prop ; @prop ; end
        def comp ; @comp ; end

        def add_prop(p) ; @prop << p ; end
        def add_comp(c) ; @comp << c ; end

        def self.factory(name)
          return eval("Component::#{name.upcase}") # xxx
        end

        def self.parse(array, name = nil)
          comp = Component::Base.factory(name || 'VCALENDAR').new

          while line = array.shift # line should be unfolded.
            case line
            when /^BEGIN:(.*)/
              comp_name = $1
              if comp.has_component?(comp_name)
                c = Component::Base.factory(comp_name).parse(array, comp_name)
                comp.add_comp c
              else
                raise "Invalid component #{comp_name} in #{self.to_s}\n"
              end
            when /^END:(.*)/
              $log.print "<<< end component #{$1}\n"
              raise "unmatch BEGIN:#{name} - END:#{$1}." if $1 != name
              return comp
            else
              p = Property::Base.factory(line).parse(line)
              comp.add_prop p
              $log.print line, "\n"
              print p.dump, "\n"
            end
          end
          raise "not found END:#{name}"
        end

        def dump
          ret = ''
          @prop.each do |p|
            ret << p.dump
          end
          @comp.each do |c|
            ret << c.dump
          end
          ret
        end
      end # class Base



      class STANDARD < Base
        # the following are each REQUIRED, but MUST NOT occur more than once

        mandatory_singleton_property 1, 'DTSTART'
        mandatory_singleton_property 1, 'TZOFFSETTO'
        mandatory_singleton_property 1, 'TZOFFSETFROM'

        # the following are optional, and MAY occur more than once

        optional_multi_property 1, 'COMMENT'
        optional_multi_property 1, 'RDATE'
        optional_multi_property 1, 'RRULE'
        optional_multi_property 1, 'TZNAME'
        optional_multi_property 1, 'X_PROP'
      end

      class DAYLIGHT < Base
        # the following are each REQUIRED, but MUST NOT occur more than once

        mandatory_singleton_property 1, 'DTSTART'
        mandatory_singleton_property 1, 'TZOFFSETTO'
        mandatory_singleton_property 1, 'TZOFFSETFROM'

        # the following are optional, and MAY occur more than once

        optional_multi_property 1, 'COMMENT'
        optional_multi_property 1, 'RDATE'
        optional_multi_property 1, 'RRULE'
        optional_multi_property 1, 'TZNAME'
        optional_multi_property 1, 'X_PROP'
      end

      class VTIMEZONE < Base

        # 'tzid' is required, but MUST NOT occur more than once

        mandatory_singleton_property 1, 'TZID'

        # 'last-mod' and 'tzurl' are optional,
        # but MUST NOT occur more than once

        optional_singleton_property 1, 'LAST-MODIFIED'
        optional_singleton_property 1, 'ZURL'

        # one of 'standardc' or 'daylightc' MUST occur
        # and each MAY occur more than once.

        mandatory_multi_component 1, 'STANDARD', 'DAYLIGHT'

        # the following is optional, and MAY occur more than once

        optional_multi_property 1, 'X_PROP'
      end

      class VCALENDAR < Base

        # 'prodid' and 'version' are both REQUIRED,
        # but MUST NOT occur more than once

        mandatory_singleton_property 1, 'PRODID'
        mandatory_singleton_property 1, 'VERSION'

        # 'calscale' and 'method' are optional,
        # but MUST NOT occur more than once

        optional_singleton_property 2, 'CALSCALE'
        optional_singleton_property 2, 'METHOD'

        # the following are optional, and MAY occur more than once

        optional_multi_property 2, 'X_PROP'

        # iCalendar MUST include at least one calendar component.

        mandatory_multi_component 3, 'VEVENT', 'VTODO', 'VJOURNAL', 'VFREEBUSY', 
                                     'VTIMEZONE', 'X_COMP'
      end

      class VEVENT < Base

        # the following are optional,
        # but MUST NOT occur more than once

        optional_singleton_property 1, 'CLASS'
        optional_singleton_property 1, 'CREATED'
        optional_singleton_property 1, 'DESCRIPTION'
        optional_singleton_property 1, 'DTSTART'  # Why not mandatory?
        optional_singleton_property 1, 'GEO'
        optional_singleton_property 1, 'LAST_MODIFIED'
        optional_singleton_property 1, 'LOCATION'
        optional_singleton_property 1, 'ORGANIZER'
        optional_singleton_property 1, 'PRIORITY'
        optional_singleton_property 1, 'DTSTAMP'
        optional_singleton_property 1, 'SEQUENCE'
        optional_singleton_property 1, 'STATUS'
        optional_singleton_property 1, 'SUMMARY'
        optional_singleton_property 1, 'TRANSP'
        optional_singleton_property 1, 'UID'
        optional_singleton_property 1, 'URL'
        optional_singleton_property 1, 'RECURRENCE_ID'

        # either 'dtend' or 'duration' may appear in
        # a 'eventprop', but 'dtend' and 'duration'
        # MUST NOT occur in the same 'eventprop'

        optional_singleton_property 1, 'DTEND', 'DURATION'

        # the following are optional, and MAY occur more than once

        optional_multi_property 1, 'ATTACH'
        optional_multi_property 1, 'ATTENDEE'
        optional_multi_property 1, 'CATEGORIES'
        optional_multi_property 1, 'COMMENT'
        optional_multi_property 1, 'CONTACT'
        optional_multi_property 1, 'EXDATE'
        optional_multi_property 1, 'EXRULE'
        optional_multi_property 1, 'RSTATUS'
        optional_multi_property 1, 'RELATED'
        optional_multi_property 1, 'RESOURCES'
        optional_multi_property 1, 'RDATE'
        optional_multi_property 1, 'RRULE'
        optional_multi_property 1, 'X_PROP'

        optional_multi_component 2, 'VALARM'
      end # VEVENT

      class VALARM < Base
      end
    end # module Component
  end # module ICalendar
end # module Mhc
