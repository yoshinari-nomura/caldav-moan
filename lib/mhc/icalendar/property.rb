################################################################
## 4.7 Calendar Properties
## 4.8 Component Properties
################################################################
module Mhc
  module ICalendar
    module Property
      class Base
        def self.factory(string)
          if string =~ /^([a-zA-Z\d-]+)/
            name = $1
            name = 'X_PROP' if name =~ /^X-/ # xxx
            $log.print("property name is #{name}")
            return eval("Property::#{name.sub('-', '_').upcase}") # xxx
          else
            raise "Invalid content line"
          end
        end

        def self.parse(string)
          if c = ContentLine.parse(string)
            return new(c.name, c.params, c.value)
          else
            raise "format error : #{string}."
          end
        end

        def initialize(name, params, value)
          @name, @params, @value = name, params, value
        end

        attr_reader :name, :params, :value

        def dump
          return "name => #{@name}, params => #{@params.inspect}, " + 
            "value =>#{@value.unescape}"
        end
      end # class Base

      ################################################################
      ## 4.7 Calendar Properties
      ################################################################

      # 4.7.1 Calendar Scale
      #
      #  Value Type: TEXT
      #
      #  calscale   = "CALSCALE" calparam ":" calvalue CRLF
      #  calparam   = *(";" xparam)
      #  calvalue   = "GREGORIAN" / iana-token
      #
      #
      class CALSCALE < Base
      end

      # 4.7.2 Method
      #
      # Value Type: TEXT
      #
      # method     = "METHOD" metparam ":" metvalue CRLF
      # metparam   = *(";" xparam)
      # metvalue   = iana-token
      #
      # Example: 
      #   METHOD:REQUEST
      class METHOD < Base
      end

      # 4.7.3 Product Identifier
      #
      # Value Type: TEXT
      #
      # Purpose: This property specifies the identifier for the product that
      # created the iCalendar object.
      #
      # prodid     = "PRODID" pidparam ":" pidvalue CRLF
      # pidparam   = *(";" xparam)
      # pidvalue   = text
      #
      # Example: 
      #   PRODID:-//ABC Corporation//NONSGML My Product//EN
      #
      class PRODID < Base
      end

      # 4.7.4 Version
      #
      # Value Type: TEXT
      #
      # version    = "VERSION" verparam ":" vervalue CRLF
      # verparam   = *(";" xparam)
      # vervalue   = "2.0"         ;This memo
      #              / maxver
      #              / (minver ";" maxver)
      # minver     = <A IANA registered iCalendar version identifier>
      #   ; Minimum iCalendar version needed to parse the iCalendar object
      # maxver     = <A IANA registered iCalendar version identifier>
      #   ; Maximum iCalendar version needed to parse the iCalendar object
      #
      # Example:
      #   VERSION:2.0
      #
      class VERSION < Base
      end

      ################################################################
      ## 4.8 Component Properties
      ################################################################

      ## 4.8.1 Descriptive Component Properties

      # 4.8.1.1 Attachment
      #
      # Value Type: URI/BINARY
      #
      # attach     = "ATTACH" attparam ":" uri  CRLF
      # attach     =/ "ATTACH" attparam ";" "ENCODING" "=" "BASE64"
      #               ";" "VALUE" "=" "BINARY" ":" binary
      # attparam   = *(
      #            ; the following is optional,
      #            ; but MUST NOT occur more than once
      #            (";" fmttypeparam) /
      #            ; the following is optional,
      #            ; and MAY occur more than once
      #            (";" xparam)
      #            )
      #
      # Example: 
      #   ATTACH:CID:jsmith.part3.960817T083000.xyzMail@host1.com
      #   ATTACH;FMTTYPE=application/postscript:ftp://xyzCorp.com/pub/
      #    reports/r-960812.ps
      #
      class ATTACH < Base
      end

      # 4.8.1.2 Categories
      #
      # Value Type: TEXT
      #
      # categories = "CATEGORIES" catparam ":" text *("," text) CRLF
      # catparam   = *(
      #            ; the following is optional,
      #            ; but MUST NOT occur more than once
      #            (";" languageparam ) /
      #            ; the following is optional,
      #            ; and MAY occur more than once
      #            (";" xparam)
      #
      #           )
      #
      # Example:
      #   CATEGORIES:APPOINTMENT,EDUCATION
      #   CATEGORIES:MEETING
      #
      class CATEGORIES < Base
      end

      # 4.8.1.3 Classification
      #
      # Value Type: TEXT
      #
      # class      = "CLASS" classparam ":" classvalue CRLF
      # classparam = *(";" xparam)
      # classvalue = "PUBLIC" / "PRIVATE" / "CONFIDENTIAL" / iana-token
      #              / x-name
      #              ; Default is PUBLIC
      #
      # Example:
      #   CLASS:PUBLIC
      #
      class CLASS < Base
      end

      # 4.8.1.4 Comment
      #
      # Value Type: TEXT
      #
      # comment    = "COMMENT" commparam ":" text CRLF
      # commparam  = *(
      #                 ; the following are optional,
      #                 ; but MUST NOT occur more than once
      #                 (";" altrepparam) / (";" languageparam) /
      #                 ; the following is optional,
      #                 ; and MAY occur more than once
      #                 (";" xparam)
      #                 )
      # Example: 
      #   COMMENT:The meeting really needs to include both ourselves
      #        and the customer. We can't hold this  meeting without them.
      #        As a matter of fact\, the venue for the meeting ought to be at
      #        their site. - - John
      #
      class COMMENT < Base
      end

      # 4.8.1.5 Description
      #
      # Value Type: TEXT
      #
      # Purpose: This property provides a more complete description of the
      # calendar component, than that provided by the "SUMMARY" property.
      #
      # description  = "DESCRIPTION" descparam ":" text CRLF
      # descparam  = *(
      #             ; the following are optional,
      #             ; but MUST NOT occur more than once
      #             (";" altrepparam) / (";" languageparam) /
      #             ; the following is optional,
      #             ; and MAY occur more than once
      #             (";" xparam)
      #             )
      #
      #  Example: 
      #    DESCRIPTION:Meeting to provide technical review for "Phoenix"
      #        design.\n Happy Face Conference Room. Phoenix design team
      #        MUST attend this meeting.\n RSVP to team leader.
      #
      class DESCRIPTION < Base
      end

      # 4.8.1.6 Geographic Position
      #
      # Value Type: two SEMICOLON separated FLOAT values.
      # 
      # Description: The property value specifies latitude and longitude, in
      # that order (i.e., "LAT LON" ordering). The longitude represents the
      # location east or west of the prime meridian as a positive or negative
      # real number, respectively. The longitude and latitude values MAY be
      # specified up to six decimal places, which will allow for accuracy to
      # within one meter of geographical position. Receiving applications
      # MUST accept values of this precision and MAY truncate values of
      # greater precision.
      #
      # Values for latitude and longitude shall be expressed as decimal
      # fractions of degrees. Whole degrees of latitude shall be represented
      # by a two-digit decimal number ranging from 0 through 90. Whole
      # degrees of longitude shall be represented by a decimal number ranging
      # from 0 through 180. When a decimal fraction of a degree is specified,
      # it shall be separated from the whole number of degrees by a decimal
      # point.
      #
      # Latitudes north of the equator shall be specified by a plus sign (+),
      # or by the absence of a minus sign (-), preceding the digits
      # designating degrees. Latitudes south of the Equator shall be
      # designated by a minus sign (-) preceding the digits designating
      # degrees. A point on the Equator shall be assigned to the Northern
      # Hemisphere.
      #
      # Longitudes east of the prime meridian shall be specified by a plus
      # sign (+), or by the absence of a minus sign (-), preceding the digits
      # designating degrees. Longitudes west of the meridian shall be
      # designated by minus sign (-) preceding the digits designating
      # degrees. A point on the prime meridian shall be assigned to the
      # Eastern Hemisphere. A point on the 180th meridian shall be assigned
      # to the Western Hemisphere. One exception to this last convention is
      # permitted. For the special condition of describing a band of latitude
      # around the earth, the East Bounding Coordinate data element shall be
      # assigned the value +180 (180) degrees.
      #
      # Any spatial address with a latitude of +90 (90) or -90 degrees will
      # specify the position at the North or South Pole, respectively. The
      # component for longitude may have any legal value.
      #
      # With the exception of the special condition described above, this
      # form is specified in Department of Commerce, 1986, Representation of
      # geographic point locations for information interchange (Federal
      # Information Processing Standard 70-1):  Washington,  Department of
      # Commerce, National Institute of Standards and Technology.
      #
      # The simple formula for converting degrees-minutes-seconds into
      # decimal degrees is:
      #
      # decimal = degrees + minutes/60 + seconds/3600.
      #
      # geo        = "GEO" geoparam ":" geovalue CRLF
      # geoparam   = *(";" xparam)
      # geovalue   = float ";" float
      #              ; Latitude and Longitude components
      #
      # Example:
      #   GEO:37.386013;-122.082932
      #
      class GEO < Base
      end

      # 4.8.1.7 Location
      #
      # Value Type: TEXT
      #
      # location   = "LOCATION locparam ":" text CRLF
      # locparam   = *(
      #            ; the following are optional,
      #            ; but MUST NOT occur more than once
      #            (";" altrepparam) / (";" languageparam) /
      #            ; the following is optional,
      #            ; and MAY occur more than once
      #            (";" xparam)
      #            )
      #
      # Example: 
      #   LOCATION:Conference Room - F123, Bldg. 002
      #   LOCATION;ALTREP="http://xyzcorp.com/conf-rooms/f123.vcf":
      #       Conference Room - F123, Bldg. 002
      #
      class LOCATION < Base
      end

      # 4.8.1.8 Percent Complete
      #
      # Value Type: INTEGER
      #
      # percent = "PERCENT-COMPLETE" pctparam ":" integer CRLF
      # pctparam   = *(";" xparam)
      #
      # Example:
      #   PERCENT-COMPLETE:39
      #
      class PERCENT_COMPLETE < Base
      end

      # 4.8.1.9 Priority
      #
      # Value Type: INTEGER
      #
      # Description: 
      #   A value of one is the highest priority. 
      #   A value of nine is the lowest priority.
      #   A value of zero specifies an undefined priority.
      #
      # A CUA (Calendar User Agent) with a three-level priority scheme
      #   "HIGH": 1 to 4
      #   "MEDIUM": 5
      #   "LOW": 6 to 9
      #
      # A CUA with a priority schema of "A1", "A2", "A3", "B1", "B2", ...,
      #   "C3" is mapped
      #   "A1": 1
      #   "A2": 2
      #     :
      #   "C3": 9
      #
      # priority   = "PRIORITY" prioparam ":" privalue CRLF
      #              ;Default is zero
      # prioparam  = *(";" xparam)
      # privalue   = integer ; Must be in the range [0..9]
      #              ; All other values are reserved for future use
      #
      # Example:
      #   PRIORITY:0
      #   (This is equivalent to not specifying the "PRIORITY" property)
      #
      class PRIORITY < Base
      end

      # 4.8.1.10 Resources
      #
      # Value Type: TEXT
      #
      # resources  = "RESOURCES" resrcparam ":" text *("," text) CRLF
      # resrcparam = *(
      #            ; the following are optional,
      #            ; but MUST NOT occur more than once
      #            (";" altrepparam) / (";" languageparam) /
      #            ; the following is optional,
      #            ; and MAY occur more than once
      #            (";" xparam)
      #            )
      #
      # Example:
      #   RESOURCES:EASEL,PROJECTOR,VCR
      #   RESOURCES;LANGUAGE=fr:1 raton-laveur
      #
      class RESOURCES < Base
      end

      # 4.8.1.11 Status
      #
      # Value Type: TEXT
      #
      # Description: In a group scheduled calendar component, the property is
      # used by the "Organizer" to provide a confirmation of the event to the
      # "Attendees". For example in a "VEVENT" calendar component, the
      # "Organizer" can indicate that a meeting is tentative, confirmed or
      # cancelled. In a "VTODO" calendar component, the "Organizer" can
      # indicate that an action item needs action, is completed, is in
      # process or being worked on, or has been cancelled. In a "VJOURNAL"
      # calendar component, the "Organizer" can indicate that a journal entry
      # is draft, final or has been cancelled or removed.
      #
      # status     = "STATUS" statparam] ":" statvalue CRLF
      # statparam  = *(";" xparam)
      # statvalue  = "TENTATIVE"           ;Indicates event is tentative.
      #            / "CONFIRMED"           ;Indicates event is definite.
      #            / "CANCELLED"           ;Indicates event was cancelled.
      #    ;Status values for a "VEVENT"
      # statvalue  =/ "NEEDS-ACTION"       ;Indicates to-do needs action.
      #            / "COMPLETED"           ;Indicates to-do completed.
      #            / "IN-PROCESS"          ;Indicates to-do in process of
      #            / "CANCELLED"           ;Indicates to-do was cancelled.
      #    ;Status values for "VTODO".
      # statvalue  =/ "DRAFT"              ;Indicates journal is draft.
      #            / "FINAL"               ;Indicates journal is final.
      #            / "CANCELLED"           ;Indicates journal is removed.
      #    ;Status values for "VJOURNAL".
      #
      # Example:
      #   for a "VEVENT":
      #     STATUS:TENTATIVE
      # for a "VTODO":
      #   STATUS:NEEDS-ACTION
      # for a "VJOURNAL":
      #   STATUS:DRAFT
      #
      class STATUS < Base
      end

      # 4.8.1.12 Summary
      #
      # Value Type: TEXT
      #
      # summary    = "SUMMARY" summparam ":" text CRLF
      # summparam  = *(
      #            ; the following are optional,
      #            ; but MUST NOT occur more than once
      #            (";" altrepparam) / (";" languageparam) /
      #            ; the following is optional,
      #            ; and MAY occur more than once
      #            (";" xparam)
      #            )
      #
      # Example:
      #   SUMMARY:Department Party
      #
      class SUMMARY < Base
      end

      ## 4.8.2 Date and Time Component Properties

      # 4.8.2.1 Date/Time Completed
      #
      # Value Type: DATE-TIME
      #
      # Conformance: The property can be specified in a "VTODO" calendar
      # component.
      #
      # Description: The date and time MUST be in a UTC format.
      #
      # completed  = "COMPLETED" compparam ":" date-time CRLF
      # compparam  = *(";" xparam)
      #
      # Example:
      #   COMPLETED:19960401T235959Z
      #
      class COMPLETED < Base
      end

      # 4.8.2.2 Date/Time End
      #
      # Value Type: The default value type is DATE-TIME. The value type can
      #             be set to a DATE value type.
      #
      # Description: Within the "VEVENT" calendar component, this property
      # defines the date and time by which the event ends. The value MUST be
      # later in time than the value of the "DTSTART" property.
      #
      # dtend      = "DTEND" dtendparam":" dtendval CRLF
      # dtendparam = *(
      #            ; the following are optional,
      #            ; but MUST NOT occur more than once
      #            (";" "VALUE" "=" ("DATE-TIME" / "DATE")) /
      #            (";" tzidparam) /
      #            ; the following is optional,
      #            ; and MAY occur more than once
      #            (";" xparam)
      #            )
      # dtendval   = date-time / date
      # ;Value MUST match value type
      #
      # Example: The following is an example of this property:
      #   DTEND:19960401T235959Z
      #   DTEND;VALUE=DATE:19980704
      #
      class DTEND < Base
      end

      # 4.8.2.3 Date/Time Due
      #
      # Value Type: The default value type is DATE-TIME. The value type can
      #              be set to a DATE value type.
      #
      # Description: The value MUST be a date/time equal to or after the
      # DTSTART value, if specified.
      #
      # due        = "DUE" dueparam":" dueval CRLF
      # dueparam   = *(
      #            ; the following are optional,
      #            ; but MUST NOT occur more than once
      #            (";" "VALUE" "=" ("DATE-TIME" / "DATE")) /
      #            (";" tzidparam) /
      #            ; the following is optional,
      #            ; and MAY occur more than once
      #              *(";" xparam)
      #            )
      # dueval     = date-time / date
      # ;Value MUST match value type
      #
      # Example: The following is an example of this property:
      #   DUE:19980430T235959Z
      #
      class DUE < Base
      end

      # 4.8.2.4 Date/Time Start
      #
      # Value Type: The default value type is DATE-TIME. The time value MUST
      #             The value type can be set to a DATE value type.
      #
      # Within the "VTIMEZONE" calendar component, this property defines the
      # effective start date and time for a time zone specification. This
      # property is REQUIRED within each STANDARD and DAYLIGHT part included
      # in "VTIMEZONE" calendar components and MUST be specified as a local
      # DATE-TIME without the "TZID" property parameter.
      #
      # dtstart    = "DTSTART" dtstparam ":" dtstval CRLF
      # dtstparam  = *(
      #            ; the following are optional,
      #            ; but MUST NOT occur more than once
      #            (";" "VALUE" "=" ("DATE-TIME" / "DATE")) /
      #            (";" tzidparam) /
      #            ; the following is optional,
      #            ; and MAY occur more than once
      #              *(";" xparam)
      #            )
      # dtstval    = date-time / date
      # ;Value MUST match value type
      #
      # Example: The following is an example of this property:
      #   DTSTART:19980118T073000Z
      #
      class DTSTART < Base
      end

      # 4.8.2.5 Duration
      #
      # Value Type: DURATION
      #
      # duration   = "DURATION" durparam ":" dur-value CRLF
      #              ;consisting of a positive duration of time.
      # durparam   = *(";" xparam)
      #
      # Example:
      #   DURATION:PT1H0M0S
      #   DURATION:PT15M
      #
      class DURATION < Base
      end

      # 4.8.2.6 Free/Busy Time
      #
      #    Value Type: PERIOD. The date and time values MUST be in an UTC time
      #    format.
      #
      # "FREEBUSY" properties within the "VFREEBUSY" calendar component
      # SHOULD be sorted in ascending order, based on start time and then end
      # time, with the earliest periods first.
      #
      # The "FREEBUSY" property can specify more than one value, separated by
      # the COMMA character (US-ASCII decimal 44). In such cases, the
      # "FREEBUSY" property values SHOULD all be of the same "FBTYPE"
      # property parameter type (e.g., all values of a particular "FBTYPE"
      # listed together in a single property).
      #
      # freebusy   = "FREEBUSY" fbparam ":" fbvalue
      #              CRLF
      # fbparam    = *(
      #            ; the following is optional,
      #            ; but MUST NOT occur more than once
      #            (";" fbtypeparam) /
      #            ; the following is optional,
      #            ; and MAY occur more than once
      #            (";" xparam)
      #            )
      # fbvalue    = period *["," period]
      # ;Time value MUST be in the UTC time format.
      #
      # Example:
      #   FREEBUSY;FBTYPE=BUSY-UNAVAILABLE:19970308T160000Z/PT8H30M
      #   FREEBUSY;FBTYPE=FREE:19970308T160000Z/PT3H,19970308T200000Z/PT1H
      #   FREEBUSY;FBTYPE=FREE:19970308T160000Z/PT3H,19970308T200000Z/PT1H,
      #    19970308T230000Z/19970309T000000Z
      #
      class FREEBUSY < Base
      end

      # 4.8.2.7 Time Transparency
      #
      #    Value Type: TEXT
      #
      # This property defines whether an event is transparent or not
      # to busy time searches.
      #
      #   transp     = "TRANSP" tranparam ":" transvalue CRLF
      #   tranparam  = *(";" xparam)
      #   transvalue = "OPAQUE"      ;Blocks or opaque on busy time searches.
      #              / "TRANSPARENT" ;Transparent on busy time searches.
      #      ; Default value is OPAQUE
      #
      # Example:
      #   TRANSP:TRANSPARENT
      #   TRANSP:OPAQUE
      #
      class TRANSP < Base
      end

      ## 4.8.3 Time Zone Component Properties

      # 4.8.3.1 Time Zone Identifier
      #
      #    Value Type: TEXT
      #
      # This property specifies the text value that uniquely
      # identifies the "VTIMEZONE" calendar component.
      #
      # Property Parameters: Non-standard property parameters can be
      # specified on this property.
      # Conformance: This property MUST be specified in a "VTIMEZONE"
      # calendar component.
      #
      #      tzid       = "TZID" tzidpropparam ":" [tzidprefix] text CRLF
      #      tzidpropparam      = *(";" xparam)
      #      ;tzidprefix        = "/"
      #      ; Defined previously. Just listed here for reader convenience.
      #
      #    Example: 
      #      TZID:US-Eastern
      #      TZID:California-Los_Angeles
      #      TZID:/US-New_York-New_York
      #
      class TZID < Base
      end

      # 4.8.3.2 Time Zone Name
      #
      #    Value Type: TEXT
      #
      # Conformance: This property can be specified in a "VTIMEZONE" calendar
      # component.
      #
      #    Description: This property may be specified in multiple
      #    languages; in order to provide for different language
      #    requirements.
      #
      #    Format Definition: This property is defined by the following
      #    notation:
      #
      #      tzname     = "TZNAME" tznparam ":" text CRLF
      #      tznparam   = *(
      #                 ; the following is optional,
      #                 ; but MUST NOT occur more than once
      #                 (";" languageparam) /
      #                 ; the following is optional,
      #                 ; and MAY occur more than once
      #                 (";" xparam)
      #                 )
      # Example:
      #   TZNAME:EST
      #   TZNAME;LANGUAGE=en:EST
      #   TZNAME;LANGUAGE=fr-CA:HNE
      #
      class TZNAME < Base
      end

      # 4.8.3.3 Time Zone Offset From
      #
      #   Value Type: UTC-OFFSET
      #
      # This property specifies the offset which is in use prior
      # to this time observance. It is used to calculate the absolute time at
      # which the transition to a given observance takes place.
      # A "VTIMEZONE" calendar component MUST include this property. The
      # property value is a signed numeric indicating the number of hours and
      # possibly minutes from UTC. Positive numbers represent time zones east
      # of the prime meridian, or ahead of UTC. Negative numbers represent
      # time zones west of the prime meridian, or behind UTC.
      #
      #  tzoffsetfrom = "TZOFFSETFROM" frmparam ":" utc-offset
      #                      CRLF
      #  frmparam   = *(";" xparam)
      #
      # Example:
      #   TZOFFSETFROM:-0500
      #   TZOFFSETFROM:+1345
      #
      class TZOFFSETFROM < Base
      end

      # 4.8.3.4 Time Zone Offset To
      #
      #    Value Type: UTC-OFFSET
      #
      # This property specifies the offset which is in use in
      # this time zone observance. It is used to calculate the absolute time
      # for the new observance. The property value is a signed numeric
      # indicating the number of hours and possibly minutes from UTC.
      # Positive numbers represent time zones east of the prime meridian, or
      # ahead of UTC. Negative numbers represent time zones west of the prime
      # meridian, or behind UTC.
      #
      #      tzoffsetto = "TZOFFSETTO" toparam ":" utc-offset CRLF
      #      toparam    = *(";" xparam)
      #
      # Example:
      #   TZOFFSETTO:-0400
      #   TZOFFSETTO:+1245
      #
      class TZOFFSETTO < Base
      end

      # 4.8.3.5 Time Zone URL
      #
      #   Value Type: URI
      #
      # Description: The TZURL provides a means for a VTIMEZONE component to
      # point to a network location that can be used to retrieve an up-to-
      # date version of itself. This provides a hook to handle changes
      # government bodies impose upon time zone definitions. Retrieval of
      # this resource results in an iCalendar object containing a single
      # VTIMEZONE component and a METHOD property set to PUBLISH.
      #
      #    tzurl      = "TZURL" tzurlparam ":" uri CRLF
      #    tzurlparam = *(";" xparam)
      #
      # Example:
      #   TZURL:http://timezones.r.us.net/tz/US-California-Los_Angeles
      #
      class TZURL < Base
      end

      ## 4.8.4 Relationship Component Properties

      # 4.8.4.1 Attendee
      #
      #   Value Type: CAL-ADDRESS
      #
      # Property Parameters: Non-standard, language, calendar user type,
      # group or list membership, participation role, participation status,
      # RSVP expectation, delegatee, delegator, sent by, common name or
      # directory entry reference property parameters can be specified on
      # this property.
      #
      # Conformance: This property MUST be specified in an iCalendar object
      # that specifies a group scheduled calendar entity. This property MUST
      # NOT be specified in an iCalendar object when publishing the calendar
      # information (e.g., NOT in an iCalendar object that specifies the
      # publication of a calendar user's busy time, event, to-do or journal).
      # This property is not specified in an iCalendar object that specifies
      # only a time zone definition or that defines calendar entities that
      # are not group scheduled entities, but are entities only on a single
      # user's calendar.
      #
      # Description: The property MUST only be specified within calendar
      # components to specify participants, non-participants and the chair of
      # a group scheduled calendar entity. The property is specified within
      # an "EMAIL" category of the "VALARM" calendar component to specify an
      # email address that is to receive the email type of iCalendar alarm.
      #
      # The property parameter CN is for the common or displayable name
      # associated with the calendar address; ROLE, for the intended role
      # that the attendee will have in the calendar component; PARTSTAT, for
      # the status of the attendee's participation; RSVP, for indicating
      # whether the favor of a reply is requested; CUTYPE, to indicate the
      # type of calendar user; MEMBER, to indicate the groups that the
      # attendee belongs to; DELEGATED-TO, to indicate the calendar users
      # that the original request was delegated to; and DELEGATED-FROM, to
      # indicate whom the request was delegated from; SENT-BY, to indicate
      # whom is acting on behalf of the ATTENDEE; and DIR, to indicate the
      # URI that points to the directory information corresponding to the
      # attendee. These property parameters can be specified on an "ATTENDEE"
      # property in either a "VEVENT", "VTODO" or "VJOURNAL" calendar
      # component. They MUST not be specified in an "ATTENDEE" property in a
      # "VFREEBUSY" or "VALARM" calendar component. If the LANGUAGE property
      # parameter is specified, the identified language applies to the CN
      # parameter.
      #
      # A recipient delegated a request MUST inherit the RSVP and ROLE values
      # from the attendee that delegated the request to them.
      #
      # Multiple attendees can be specified by including multiple "ATTENDEE"
      # properties within the calendar component.
      #
      # Format Definition: The property is defined by the following notation:
      #
      #      attendee   = "ATTENDEE" attparam ":" cal-address CRLF
      #      attparam   = *(
      #                 ; the following are optional,
      #                 ; but MUST NOT occur more than once
      #                 (";" cutypeparam) / (";"memberparam) /
      #                 (";" roleparam) / (";" partstatparam) /
      #                 (";" rsvpparam) / (";" deltoparam) /
      #                 (";" delfromparam) / (";" sentbyparam) /
      #                 (";"cnparam) / (";" dirparam) /
      #                 (";" languageparam) /
      #                 ; the following is optional,
      #                 ; and MAY occur more than once
      #                 (";" xparam)
      #                 )
      # Example:
      #  ORGANIZER:MAILTO:jsmith@host1.com
      #  ATTENDEE;MEMBER="MAILTO:DEV-GROUP@host2.com":
      #    MAILTO:joecool@host2.com
      #  ATTENDEE;DELEGATED-FROM="MAILTO:immud@host3.com":
      #    MAILTO:ildoit@host1.com
      #
      # The following is an example of this property used for specifying
      # multiple attendees to an event:
      #   ORGANIZER:MAILTO:jsmith@host1.com
      #   ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=TENTATIVE;CN=Henry Cabot
      #    :MAILTO:hcabot@host2.com
      #   ATTENDEE;ROLE=REQ-PARTICIPANT;DELEGATED-FROM="MAILTO:bob@host.com"
      #    ;PARTSTAT=ACCEPTED;CN=Jane Doe:MAILTO:jdoe@host1.com
      #
      # The following is an example of this property with a URI to the
      # directory information associated with the attendee:
      #
      #   ATTENDEE;CN=John Smith;DIR="ldap://host.com:6666/o=eDABC%
      #     20Industries,c=3DUS??(cn=3DBJim%20Dolittle)":MAILTO:jimdo@
      #     host1.com
      #
      # The following is an example of this property with "delegatee" and
      # "delegator" information for an event:
      #
      #   ORGANIZER;CN=John Smith:MAILTO:jsmith@host.com
      #   ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=TENTATIVE;DELEGATED-FROM=
      #    "MAILTO:iamboss@host2.com";CN=Henry Cabot:MAILTO:hcabot@
      #    host2.com
      #   ATTENDEE;ROLE=NON-PARTICIPANT;PARTSTAT=DELEGATED;DELEGATED-TO=
      #    "MAILTO:hcabot@host2.com";CN=The Big Cheese:MAILTO:iamboss
      #    @host2.com
      #   ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=ACCEPTED;CN=Jane Doe
      #    :MAILTO:jdoe@host1.com
      #
      # Example: The following is an example of this property's use when
      # another calendar user is acting on behalf of the "Attendee":
      #
      #   ATTENDEE;SENT-BY=MAILTO:jan_doe@host1.com;CN=John Smith:MAILTO:
      #    jsmith@host1.com
      #
      class ATTENDEE < Base
      end

      # 4.8.4.2 Contact
      #
      #   Value Type: TEXT
      #
      # Property Parameters: Non-standard, alternate text representation and
      # language property parameters can be specified on this property.
      #
      # Conformance: The property can be specified in a "VEVENT", "VTODO",
      # "VJOURNAL" or "VFREEBUSY" calendar component.
      #
      # Description: The property value consists of textual contact
      # information. An alternative representation for the property value can
      # also be specified that refers to a URI pointing to an alternate form,
      # such as a vCard [RFC 2426], for the contact information.
      # Format Definition: The property is defined by the following notation:
      #
      #      contact    = "CONTACT" contparam ":" text CRLF
      #      contparam  = *(
      #                 ; the following are optional,
      #                 ; but MUST NOT occur more than once
      #                 (";" altrepparam) / (";" languageparam) /
      #                 ; the following is optional,
      #                 ; and MAY occur more than once
      #                 (";" xparam)
      #                 )
      #
      # Example:
      #    textual contact information:
      #    CONTACT:Jim Dolittle\, ABC Industries\, +1-919-555-1234
      #
      #   CONTACT;ALTREP="ldap://host.com:6666/o=3DABC%20Industries\,
      #   c=3DUS??(cn=3DBJim%20Dolittle)":Jim Dolittle\, ABC Industries\,
      #   +1-919-555-1234
      #
      #  The following is an example of this property with an alternate
      #  representation of a MIME body part containing the contact
      #  information, such as a vCard [RFC 2426] embedded in a [MIME-DIR]
      #  content-type:
      #
      #    CONTACT;ALTREP="CID=<part3.msg970930T083000SILVER@host.com>":Jim
      #      Dolittle\, ABC Industries\, +1-919-555-1234
      #
      # The following is an example of this property referencing a network
      # resource, such as a vCard [RFC 2426] object containing the contact
      # information:
      #
      #   CONTACT;ALTREP="http://host.com/pdi/jdoe.vcf":Jim
      #     Dolittle\, ABC Industries\, +1-919-555-1234
      #
      class CONTACT < Base
      end

      # 4.8.4.3 Organizer
      #
      #    Value Type: CAL-ADDRESS
      #
      # Property Parameters: Non-standard, language, common name, directory
      # entry reference, sent by property parameters can be specified on this
      # property.
      #
      # Conformance: This property MUST be specified in an iCalendar object
      # that specifies a group scheduled calendar entity. This property MUST
      # be specified in an iCalendar object that specifies the publication of
      # a calendar user's busy time. This property MUST NOT be specified in
      # an iCalendar object that specifies only a time zone definition or
      # that defines calendar entities that are not group scheduled entities,
      # but are entities only on a single user's calendar.
      #
      # Description: The property is specified within the "VEVENT", "VTODO",
      # "VJOURNAL calendar components to specify the organizer of a group
      # scheduled calendar entity. The property is specified within the
      # "VFREEBUSY" calendar component to specify the calendar user
      # requesting the free or busy time. When publishing a "VFREEBUSY"
      # calendar component, the property is used to specify the calendar that
      # the published busy time came from.
      #
      # The property has the property parameters CN, for specifying the
      # common or display name associated with the "Organizer", DIR, for
      # specifying a pointer to the directory information associated with the
      # "Organizer", SENT-BY, for specifying another calendar user that is
      # acting on behalf of the "Organizer". The non-standard parameters may
      # also be specified on this property. If the LANGUAGE property
      # parameter is specified, the identified language applies to the CN
      # parameter value.
      #
      # Format Definition: The property is defined by the following notation:
      #      organizer  = "ORGANIZER" orgparam ":"
      #                   cal-address CRLF
      #      orgparam   = *(
      #                 ; the following are optional,
      #                 ; but MUST NOT occur more than once
      #                 (";" cnparam) / (";" dirparam) / (";" sentbyparam) /
      #                 (";" languageparam) /
      #                 ; the following is optional,
      #                 ; and MAY occur more than once
      #                 (";" xparam)
      #                 )
      # Example: The following is an example of this property:
      #      ORGANIZER;CN=John Smith:MAILTO:jsmith@host1.com
      #
      # The following is an example of this property with a pointer to the
      # directory information associated with the organizer:
      #
      #      ORGANIZER;CN=JohnSmith;DIR="ldap://host.com:6666/o=3DDC%20Associ
      #       ates,c=3DUS??(cn=3DJohn%20Smith)":MAILTO:jsmith@host1.com
      #
      # The following is an example of this property used by another calendar
      # user who is acting on behalf of the organizer, with responses
      # intended to be sent back to the organizer, not the other calendar
      # user:
      #
      #      ORGANIZER;SENT-BY="MAILTO:jane_doe@host.com":
      #       MAILTO:jsmith@host1.com
      #
      class ORGANIZER < Base
      end

      # 4.8.4.4 Recurrence ID
      #
      # Purpose: This property is used in conjunction with the "UID" and
      # "SEQUENCE" property to identify a specific instance of a recurring
      # "VEVENT", "VTODO" or "VJOURNAL" calendar component. The property
      # value is the effective value of the "DTSTART" property of the
      # recurrence instance.
      #
      # Value Type: The default value type for this property is DATE-TIME.
      # The time format can be any of the valid forms defined for a DATE-TIME
      # value type. See DATE-TIME value type definition for specific
      # interpretations of the various forms. The value type can be set to
      # DATE.
      #
      # Property Parameters: Non-standard property, value data type, time
      # zone identifier and recurrence identifier range parameters can be
      # specified on this property.
      #
      # Conformance: This property can be specified in an iCalendar object
      # containing a recurring calendar component.
      #
      # Description: The full range of calendar components specified by a
      # recurrence set is referenced by referring to just the "UID" property
      # value corresponding to the calendar component. The "RECURRENCE-ID"
      # property allows the reference to an individual instance within the
      # recurrence set.
      #
      # If the value of the "DTSTART" property is a DATE type value, then the
      # value MUST be the calendar date for the recurrence instance.
      #
      # The date/time value is set to the time when the original recurrence
      # instance would occur; meaning that if the intent is to change a
      # Friday meeting to Thursday, the date/time is still set to the
      # original Friday meeting.

      # The "RECURRENCE-ID" property is used in conjunction with the "UID"
      # and "SEQUENCE" property to identify a particular instance of a
      # recurring event, to-do or journal. For a given pair of "UID" and
      # "SEQUENCE" property values, the "RECURRENCE-ID" value for a
      # recurrence instance is fixed. When the definition of the recurrence
      # set for a calendar component changes, and hence the "SEQUENCE"
      # property value changes, the "RECURRENCE-ID" for a given recurrence
      # instance might also change.The "RANGE" parameter is used to specify
      # the effective range of recurrence instances from the instance
      # specified by the "RECURRENCE-ID" property value. The default value
      # for the range parameter is the single recurrence instance only. The
      # value can also be "THISANDPRIOR" to indicate a range defined by the
      # given recurrence instance and all prior instances or the value can be
      # "THISANDFUTURE" to indicate a range defined by the given recurrence
      # instance and all subsequent instances.
      #
      # Format Definition: The property is defined by the following notation:
      #      recurid    = "RECURRENCE-ID" ridparam ":" ridval CRLF
      #      ridparam   = *(
      #                 ; the following are optional,
      #                 ; but MUST NOT occur more than once
      #                 (";" "VALUE" "=" ("DATE-TIME" / "DATE)) /
      #                 (";" tzidparam) / (";" rangeparam) /
      #                 ; the following is optional,
      #                 ; and MAY occur more than once
      #                 (";" xparam)
      #                 )
      #      ridval     = date-time / date
      #      ;Value MUST match value type
      #
      # Example: The following are examples of this property:
      #
      #      RECURRENCE-ID;VALUE=DATE:19960401
      #      RECURRENCE-ID;RANGE=THISANDFUTURE:19960120T120000Z
      #
      class RECURRENCE_ID < Base
      end

      # 4.8.4.5 Related To
      #
      # Purpose: The property is used to represent a relationship or
      # reference between one calendar component and another.
      #
      # Value Type: TEXT
      #
      # Property Parameters: Non-standard and relationship type property
      # parameters can be specified on this property.
      #
      # Conformance: The property can be specified one or more times in the
      # "VEVENT", "VTODO" or "VJOURNAL" calendar components.
      #
      # Description: The property value consists of the persistent, globally
      # unique identifier of another calendar component. This value would be
      # represented in a calendar component by the "UID" property.
      #
      # By default, the property value points to another calendar component
      # that has a PARENT relationship to the referencing object. The
      # "RELTYPE" property parameter is used to either explicitly state the
      # default PARENT relationship type to the referenced calendar component
      # or to override the default PARENT relationship type and specify
      # either a CHILD or SIBLING relationship. The PARENT relationship
      # indicates that the calendar component is a subordinate of the
      # referenced calendar component. The CHILD relationship indicates that
      # the calendar component is a superior of the referenced calendar
      # component. The SIBLING relationship indicates that the calendar
      # component is a peer of the referenced calendar component.
      #
      # Changes to a calendar component referenced by this property can have
      # an implicit impact on the related calendar component. For example, if
      # a group event changes its start or end date or time, then the
      # related, dependent events will need to have their start and end dates
      # changed in a corresponding way. Similarly, if a PARENT calendar
      # component is canceled or deleted, then there is an implied impact to
      # the related CHILD calendar components. This property is intended only
      # to provide information on the relationship of calendar components. It
      # is up to the target calendar system to maintain any property
      # implications of this relationship.
      #
      # Format Definition: The property is defined by the following notation:
      #      related    = "RELATED-TO" [relparam] ":" text CRLF
      #      relparam   = *(
      #                 ; the following is optional,
      #                 ; but MUST NOT occur more than once
      #                 (";" reltypeparam) /
      #                 ; the following is optional,
      #                 ; and MAY occur more than once
      #                 (";" xparm)
      #                 )
      #
      # The following is an example of this property:
      #
      #      RELATED-TO:<jsmith.part7.19960817T083000.xyzMail@host3.com>
      #      RELATED-TO:<19960401-080045-4000F192713-0052@host1.com>
      #
      class RELATED_TO < Base
      end

      # 4.8.4.6 Uniform Resource Locator
      #
      # Purpose: This property defines a Uniform Resource Locator (URL)
      # associated with the iCalendar object.
      #
      # Value Type: URI
      #
      # Property Parameters: Non-standard property parameters can be
      # specified on this property.
      #
      # Conformance: This property can be specified once in the "VEVENT",
      # "VTODO", "VJOURNAL" or "VFREEBUSY" calendar components.
      #
      # Description: This property may be used in a calendar component to
      # convey a location where a more dynamic rendition of the calendar
      # information associated with the calendar component can be found. This
      # memo does not attempt to standardize the form of the URI, nor the
      # format of the resource pointed to by the property value. If the URL
      # property and Content-Location MIME header are both specified, they
      # MUST point to the same resource.
      #
      # Format Definition: The property is defined by the following notation:
      #
      #      url        = "URL" urlparam ":" uri CRLF
      #      urlparam   = *(";" xparam)
      #
      # Example: The following is an example of this property:
      #
      #      URL:http://abc.com/pub/calendars/jsmith/mytime.ics
      #
      class URL < Base
      end

      # 4.8.4.7 Unique Identifier
      #
      # Purpose: This property defines the persistent, globally unique
      # identifier for the calendar component.
      #
      # Value Type: TEXT
      #
      # Property Parameters: Non-standard property parameters can be
      # specified on this property.
      #
      # Conformance: The property MUST be specified in the "VEVENT", "VTODO",
      # "VJOURNAL" or "VFREEBUSY" calendar components.
      #
      # Description: The UID itself MUST be a globally unique identifier. The
      # generator of the identifier MUST guarantee that the identifier is
      # unique. There are several algorithms that can be used to accomplish
      # this. The identifier is RECOMMENDED to be the identical syntax to the
      # [RFC 822] addr-spec. A good method to assure uniqueness is to put the
      # domain name or a domain literal IP address of the host on which the
      # identifier was created on the right hand side of the "@", and on the
      # left hand side, put a combination of the current calendar date and
      # time of day (i.e., formatted in as a DATE-TIME value) along with some
      # other currently unique (perhaps sequential) identifier available on
      # the system (for example, a process id number). Using a date/time
      # value on the left hand side and a domain name or domain literal on
      # the right hand side makes it possible to guarantee uniqueness since
      # no two hosts should be using the same domain name or IP address at
      # the same time. Though other algorithms will work, it is RECOMMENDED
      # that the right hand side contain some domain identifier (either of
      # the host itself or otherwise) such that the generator of the message
      # identifier can guarantee the uniqueness of the left hand side within
      # the scope of that domain.
      #
      # This is the method for correlating scheduling messages with the
      # referenced "VEVENT", "VTODO", or "VJOURNAL" calendar component.
      #
      # The full range of calendar components specified by a recurrence set
      # is referenced by referring to just the "UID" property value
      # corresponding to the calendar component. The "RECURRENCE-ID" property
      # allows the reference to an individual instance within the recurrence
      # set.
      #
      # This property is an important method for group scheduling
      # applications to match requests with later replies, modifications or
      # deletion requests. Calendaring and scheduling applications MUST
      # generate this property in "VEVENT", "VTODO" and "VJOURNAL" calendar
      # components to assure interoperability with other group scheduling
      # applications. This identifier is created by the calendar system that
      # generates an iCalendar object.
      #
      # Implementations MUST be able to receive and persist values of at
      # least 255 characters for this property.
      #
      # Format Definition: The property is defined by the following notation:
      #
      #      uid        = "UID" uidparam ":" text CRLF
      #      uidparam   = *(";" xparam)
      #
      # Example: The following is an example of this property:
      #
      #      UID:19960401T080045Z-4000F192713-0052@host1.com
      #
      class UID < Base
      end

      ## 4.8.5 Recurrence Component Properties

      # 4.8.5.1 Exception Date/Times
      #
      # Purpose: This property defines the list of date/time exceptions for a
      # recurring calendar component.
      #
      # Value Type: The default value type for this property is DATE-TIME.
      # The value type can be set to DATE.
      #
      # Property Parameters: Non-standard, value data type and time zone
      # identifier property parameters can be specified on this property.
      #
      # Conformance: This property can be specified in an iCalendar object
      # that includes a recurring calendar component.
      #
      # Description: The exception dates, if specified, are used in computing
      # the recurrence set. The recurrence set is the complete set of
      # recurrence instances for a calendar component. The recurrence set is
      # generated by considering the initial "DTSTART" property along with
      # the "RRULE", "RDATE", "EXDATE" and "EXRULE" properties contained
      # within the iCalendar object. The "DTSTART" property defines the first
      # instance in the recurrence set. Multiple instances of the "RRULE" and
      # "EXRULE" properties can also be specified to define more
      # sophisticated recurrence sets. The final recurrence set is generated
      # by gathering all of the start date-times generated by any of the
      # specified "RRULE" and "RDATE" properties, and then excluding any
      # start date and times which fall within the union of start date and
      # times generated by any specified "EXRULE" and "EXDATE" properties.
      # This implies that start date and times within exclusion related
      # properties (i.e., "EXDATE" and "EXRULE") take precedence over those
      # specified by inclusion properties (i.e., "RDATE" and "RRULE"). Where
      # duplicate instances are generated by the "RRULE" and "RDATE"
      # properties, only one recurrence is considered. Duplicate instances
      # are ignored.
      #
      # The "EXDATE" property can be used to exclude the value specified in
      # "DTSTART". However, in such cases the original "DTSTART" date MUST
      # still be maintained by the calendaring and scheduling system because
      # the original "DTSTART" value has inherent usage dependencies by other
      # properties such as the "RECURRENCE-ID".
      #
      # Format Definition: The property is defined by the following notation:
      #
      #      exdate     = "EXDATE" exdtparam ":" exdtval *("," exdtval) CRLF
      #      exdtparam  = *(
      #                 ; the following are optional,
      #                 ; but MUST NOT occur more than once
      #                 (";" "VALUE" "=" ("DATE-TIME" / "DATE")) /
      #                 (";" tzidparam) /
      #                 ; the following is optional,
      #                 ; and MAY occur more than once
      #                 (";" xparam)
      #                 )
      #      exdtval    = date-time / date
      #      ;Value MUST match value type
      #
      # Example: The following is an example of this property:
      #
      #      EXDATE:19960402T010000Z,19960403T010000Z,19960404T010000Z
      #
      class EXDATE < Base
      end

      # 4.8.5.2 Exception Rule
      #
      # Purpose: This property defines a rule or repeating pattern for an
      # exception to a recurrence set.
      #
      # Value Type: RECUR
      #
      # Property Parameters: Non-standard property parameters can be
      # specified on this property.
      #
      # Conformance: This property can be specified in "VEVENT", "VTODO" or
      # "VJOURNAL" calendar components.
      #
      # Description: The exception rule, if specified, is used in computing
      # the recurrence set. The recurrence set is the complete set of
      # recurrence instances for a calendar component. The recurrence set is
      # generated by considering the initial "DTSTART" property along with
      # the "RRULE", "RDATE", "EXDATE" and "EXRULE" properties contained
      # within the iCalendar object. The "DTSTART" defines the first instance
      # in the recurrence set. Multiple instances of the "RRULE" and "EXRULE"
      # properties can also be specified to define more sophisticated
      # recurrence sets. The final recurrence set is generated by gathering
      # all of the start date-times generated by any of the specified "RRULE"
      # and "RDATE" properties, and excluding any start date and times which
      # fall within the union of start date and times generated by any
      # specified "EXRULE" and "EXDATE" properties. This implies that start
      # date and times within exclusion related properties (i.e., "EXDATE"
      # and "EXRULE") take precedence over those specified by inclusion
      # properties (i.e., "RDATE" and "RRULE"). Where duplicate instances are
      # generated by the "RRULE" and "RDATE" properties, only one recurrence
      # is considered. Duplicate instances are ignored.
      #
      # The "EXRULE" property can be used to exclude the value specified in
      # "DTSTART". However, in such cases the original "DTSTART" date MUST
      # still be maintained by the calendaring and scheduling system because
      # the original "DTSTART" value has inherent usage dependencies by other
      # properties such as the "RECURRENCE-ID".
      #
      # Format Definition: The property is defined by the following notation:
      #
      #      exrule     = "EXRULE" exrparam ":" recur CRLF
      #      exrparam   = *(";" xparam)
      #
      # Example: The following are examples of this property. Except every
      # other week, on Tuesday and Thursday for 4 occurrences:
      #
      #      EXRULE:FREQ=WEEKLY;COUNT=4;INTERVAL=2;BYDAY=TU,TH
      #
      #    Except daily for 10 occurrences:
      #
      #      EXRULE:FREQ=DAILY;COUNT=10
      #
      #    Except yearly in June and July for 8 occurrences:
      #
      #      EXRULE:FREQ=YEARLY;COUNT=8;BYMONTH=6,7
      #
      class EXRULE < Base
      end

      # 4.8.5.3 Recurrence Date/Times
      #
      # Purpose: This property defines the list of date/times for a
      # recurrence set.
      #
      # Value Type: The default value type for this property is DATE-TIME.
      # The value type can be set to DATE or PERIOD.
      #
      # Property Parameters: Non-standard, value data type and time zone
      # identifier property parameters can be specified on this property.
      #
      # Conformance: The property can be specified in "VEVENT", "VTODO",
      # "VJOURNAL" or "VTIMEZONE" calendar components.
      #
      # Description: This property can appear along with the "RRULE" property
      # to define an aggregate set of repeating occurrences. When they both
      # appear in an iCalendar object, the recurring events are defined by
      # the union of occurrences defined by both the "RDATE" and "RRULE".
      #
      # The recurrence dates, if specified, are used in computing the
      # recurrence set. The recurrence set is the complete set of recurrence
      # instances for a calendar component. The recurrence set is generated
      # by considering the initial "DTSTART" property along with the "RRULE",
      # "RDATE", "EXDATE" and "EXRULE" properties contained within the
      # iCalendar object. The "DTSTART" property defines the first instance
      # in the recurrence set. Multiple instances of the "RRULE" and "EXRULE"
      # properties can also be specified to define more sophisticated
      # recurrence sets. The final recurrence set is generated by gathering
      # all of the start date/times generated by any of the specified "RRULE"
      # and "RDATE" properties, and excluding any start date/times which fall
      # within the union of start date/times generated by any specified
      # "EXRULE" and "EXDATE" properties. This implies that start date/times
      # within exclusion related properties (i.e., "EXDATE" and "EXRULE")
      # take precedence over those specified by inclusion properties (i.e.,
      # "RDATE" and "RRULE"). Where duplicate instances are generated by the
      # "RRULE" and "RDATE" properties, only one recurrence is considered.
      # Duplicate instances are ignored.
      #
      # Format Definition: The property is defined by the following notation:
      #
      #      rdate      = "RDATE" rdtparam ":" rdtval *("," rdtval) CRLF
      #      rdtparam   = *(
      #                 ; the following are optional,
      #                 ; but MUST NOT occur more than once
      #                 (";" "VALUE" "=" ("DATE-TIME" / "DATE" / "PERIOD")) /
      #                 (";" tzidparam) /
      #                 ; the following is optional,
      #                 ; and MAY occur more than once
      #                 (";" xparam)
      #                 )
      #      rdtval     = date-time / date / period
      #      ;Value MUST match value type
      #
      # Example: The following are examples of this property:
      #
      #      RDATE:19970714T123000Z
      #      RDATE;TZID=US-EASTERN:19970714T083000
      #      RDATE;VALUE=PERIOD:19960403T020000Z/19960403T040000Z,
      #       19960404T010000Z/PT3H
      #      RDATE;VALUE=DATE:19970101,19970120,19970217,19970421
      #       19970526,19970704,19970901,19971014,19971128,19971129,19971225
      #
      class RDATE < Base
      end

      # 4.8.5.4 Recurrence Rule
      #
      # Purpose: This property defines a rule or repeating pattern for
      # recurring events, to-dos, or time zone definitions.
      #
      # Value Type: RECUR
      #
      # Property Parameters: Non-standard property parameters can be
      # specified on this property.
      #
      # Conformance: This property can be specified one or more times in
      # recurring "VEVENT", "VTODO" and "VJOURNAL" calendar components. It
      # can also be specified once in each STANDARD or DAYLIGHT sub-component
      # of the "VTIMEZONE" calendar component.
      #
      # Description: The recurrence rule, if specified, is used in computing
      # the recurrence set. The recurrence set is the complete set of
      # recurrence instances for a calendar component. The recurrence set is
      # generated by considering the initial "DTSTART" property along with
      # the "RRULE", "RDATE", "EXDATE" and "EXRULE" properties contained
      # within the iCalendar object. The "DTSTART" property defines the first
      # instance in the recurrence set. Multiple instances of the "RRULE" and
      # "EXRULE" properties can also be specified to define more
      # sophisticated recurrence sets. The final recurrence set is generated
      # by gathering all of the start date/times generated by any of the
      # specified "RRULE" and "RDATE" properties, and excluding any start
      # date/times which fall within the union of start date/times generated
      # by any specified "EXRULE" and "EXDATE" properties. This implies that
      # start date/times within exclusion related properties (i.e., "EXDATE"
      # and "EXRULE") take precedence over those specified by inclusion
      # properties (i.e., "RDATE" and "RRULE"). Where duplicate instances are
      # generated by the "RRULE" and "RDATE" properties, only one recurrence
      # is considered. Duplicate instances are ignored.
      #
      # The "DTSTART" and "DTEND" property pair or "DTSTART" and "DURATION"
      # property pair, specified within the iCalendar object defines the
      # first instance of the recurrence. When used with a recurrence rule,
      # the "DTSTART" and "DTEND" properties MUST be specified in local time
      # and the appropriate set of "VTIMEZONE" calendar components MUST be
      # included. For detail on the usage of the "VTIMEZONE" calendar
      # component, see the "VTIMEZONE" calendar component definition.
      #
      # Any duration associated with the iCalendar object applies to all
      # members of the generated recurrence set. Any modified duration for
      # specific recurrences MUST be explicitly specified using the "RDATE"
      # property.
      #
      # Format Definition: This property is defined by the following
      # notation:
      #
      #      rrule      = "RRULE" rrulparam ":" recur CRLF
      #      rrulparam  = *(";" xparam)
      #
      # Example: All examples assume the Eastern United States time zone.
      #
      #    Daily for 10 occurrences:
      #
      #      DTSTART;TZID=US-Eastern:19970902T090000
      #      RRULE:FREQ=DAILY;COUNT=10
      #
      #      ==> (1997 9:00 AM EDT)September 2-11
      #
      #    Daily until December 24, 1997:
      #
      #      DTSTART;TZID=US-Eastern:19970902T090000
      #      RRULE:FREQ=DAILY;UNTIL=19971224T000000Z
      #
      #      ==> (1997 9:00 AM EDT)September 2-30;October 1-25
      #          (1997 9:00 AM EST)October 26-31;November 1-30;December 1-23
      #
      #    Every other day - forever:
      #
      #      DTSTART;TZID=US-Eastern:19970902T090000
      #      RRULE:FREQ=DAILY;INTERVAL=2
      #      ==> (1997 9:00 AM EDT)September2,4,6,8...24,26,28,30;
      #           October 2,4,6...20,22,24
      #          (1997 9:00 AM EST)October 26,28,30;November 1,3,5,7...25,27,29;
      #           Dec 1,3,...
      #
      #    Every 10 days, 5 occurrences:
      #
      #      DTSTART;TZID=US-Eastern:19970902T090000
      #      RRULE:FREQ=DAILY;INTERVAL=10;COUNT=5
      #
      #      ==> (1997 9:00 AM EDT)September 2,12,22;October 2,12
      #
      #    Everyday in January, for 3 years:
      #
      #      DTSTART;TZID=US-Eastern:19980101T090000
      #      RRULE:FREQ=YEARLY;UNTIL=20000131T090000Z;
      #       BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA
      #      or
      #      RRULE:FREQ=DAILY;UNTIL=20000131T090000Z;BYMONTH=1
      #
      #      ==> (1998 9:00 AM EDT)January 1-31
      #          (1999 9:00 AM EDT)January 1-31
      #          (2000 9:00 AM EDT)January 1-31
      #
      #    Weekly for 10 occurrences
      #
      #      DTSTART;TZID=US-Eastern:19970902T090000
      #      RRULE:FREQ=WEEKLY;COUNT=10
      #
      #      ==> (1997 9:00 AM EDT)September 2,9,16,23,30;October 7,14,21
      #          (1997 9:00 AM EST)October 28;November 4
      #
      #    Weekly until December 24, 1997
      #
      #      DTSTART;TZID=US-Eastern:19970902T090000
      #      RRULE:FREQ=WEEKLY;UNTIL=19971224T000000Z
      #
      #      ==> (1997 9:00 AM EDT)September 2,9,16,23,30;October 7,14,21
      #          (1997 9:00 AM EST)October 28;November 4,11,18,25;
      #                            December 2,9,16,23
      #    Every other week - forever:
      #
      #      DTSTART;TZID=US-Eastern:19970902T090000
      #      RRULE:FREQ=WEEKLY;INTERVAL=2;WKST=SU
      #
      #      ==> (1997 9:00 AM EDT)September 2,16,30;October 14
      #          (1997 9:00 AM EST)October 28;November 11,25;December 9,23
      #          (1998 9:00 AM EST)January 6,20;February
      #      ...
      #
      #    Weekly on Tuesday and Thursday for 5 weeks:
      #
      #     DTSTART;TZID=US-Eastern:19970902T090000
      #     RRULE:FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH
      #     or
      #     RRULE:FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH
      #
      #     ==> (1997 9:00 AM EDT)September 2,4,9,11,16,18,23,25,30;October 2
      #
      #    Every other week on Monday, Wednesday and Friday until December 24,
      #    1997, but starting on Tuesday, September 2, 1997:
      #
      #      DTSTART;TZID=US-Eastern:19970902T090000
      #      RRULE:FREQ=WEEKLY;INTERVAL=2;UNTIL=19971224T000000Z;WKST=SU;
      #       BYDAY=MO,WE,FR
      #      ==> (1997 9:00 AM EDT)September 2,3,5,15,17,19,29;October
      #      1,3,13,15,17
      #          (1997 9:00 AM EST)October 27,29,31;November 10,12,14,24,26,28;
      #                            December 8,10,12,22
      #
      #    Every other week on Tuesday and Thursday, for 8 occurrences:
      #
      #      DTSTART;TZID=US-Eastern:19970902T090000
      #      RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=8;WKST=SU;BYDAY=TU,TH
      #
      #      ==> (1997 9:00 AM EDT)September 2,4,16,18,30;October 2,14,16
      #
      #    Monthly on the 1st Friday for ten occurrences:
      #
      #      DTSTART;TZID=US-Eastern:19970905T090000
      #      RRULE:FREQ=MONTHLY;COUNT=10;BYDAY=1FR
      #
      #      ==> (1997 9:00 AM EDT)September 5;October 3
      #          (1997 9:00 AM EST)November 7;Dec 5
      #          (1998 9:00 AM EST)January 2;February 6;March 6;April 3
      #          (1998 9:00 AM EDT)May 1;June 5
      #
      #    Monthly on the 1st Friday until December 24, 1997:
      #
      #      DTSTART;TZID=US-Eastern:19970905T090000
      #      RRULE:FREQ=MONTHLY;UNTIL=19971224T000000Z;BYDAY=1FR
      #
      #      ==> (1997 9:00 AM EDT)September 5;October 3
      #          (1997 9:00 AM EST)November 7;December 5
      #
      #    Every other month on the 1st and last Sunday of the month for 10
      #    occurrences:
      #
      #      DTSTART;TZID=US-Eastern:19970907T090000
      #      RRULE:FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU
      #
      #      ==> (1997 9:00 AM EDT)September 7,28
      #          (1997 9:00 AM EST)November 2,30
      #          (1998 9:00 AM EST)January 4,25;March 1,29
      #          (1998 9:00 AM EDT)May 3,31
      #
      #    Monthly on the second to last Monday of the month for 6 months:
      #
      #      DTSTART;TZID=US-Eastern:19970922T090000
      #      RRULE:FREQ=MONTHLY;COUNT=6;BYDAY=-2MO
      #
      #      ==> (1997 9:00 AM EDT)September 22;October 20
      #          (1997 9:00 AM EST)November 17;December 22
      #          (1998 9:00 AM EST)January 19;February 16
      #
      #    Monthly on the third to the last day of the month, forever:
      #
      #      DTSTART;TZID=US-Eastern:19970928T090000
      #      RRULE:FREQ=MONTHLY;BYMONTHDAY=-3
      #
      #      ==> (1997 9:00 AM EDT)September 28
      #          (1997 9:00 AM EST)October 29;November 28;December 29
      #          (1998 9:00 AM EST)January 29;February 26
      #      ...
      #
      #    Monthly on the 2nd and 15th of the month for 10 occurrences:
      #
      #      DTSTART;TZID=US-Eastern:19970902T090000
      #      RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=2,15
      #
      #      ==> (1997 9:00 AM EDT)September 2,15;October 2,15
      #          (1997 9:00 AM EST)November 2,15;December 2,15
      #          (1998 9:00 AM EST)January 2,15
      #
      #    Monthly on the first and last day of the month for 10 occurrences:
      #
      #      DTSTART;TZID=US-Eastern:19970930T090000
      #      RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=1,-1
      #
      #      ==> (1997 9:00 AM EDT)September 30;October 1
      #          (1997 9:00 AM EST)October 31;November 1,30;December 1,31
      #          (1998 9:00 AM EST)January 1,31;February 1
      #
      #    Every 18 months on the 10th thru 15th of the month for 10
      #    occurrences:
      #
      #      DTSTART;TZID=US-Eastern:19970910T090000
      #      RRULE:FREQ=MONTHLY;INTERVAL=18;COUNT=10;BYMONTHDAY=10,11,12,13,14,
      #       15
      #
      #      ==> (1997 9:00 AM EDT)September 10,11,12,13,14,15
      #          (1999 9:00 AM EST)March 10,11,12,13
      #
      #    Every Tuesday, every other month:
      #
      #      DTSTART;TZID=US-Eastern:19970902T090000
      #      RRULE:FREQ=MONTHLY;INTERVAL=2;BYDAY=TU
      #
      #      ==> (1997 9:00 AM EDT)September 2,9,16,23,30
      #          (1997 9:00 AM EST)November 4,11,18,25
      #          (1998 9:00 AM EST)January 6,13,20,27;March 3,10,17,24,31
      #      ...
      #
      #    Yearly in June and July for 10 occurrences:
      #
      #      DTSTART;TZID=US-Eastern:19970610T090000
      #      RRULE:FREQ=YEARLY;COUNT=10;BYMONTH=6,7
      #      ==> (1997 9:00 AM EDT)June 10;July 10
      #          (1998 9:00 AM EDT)June 10;July 10
      #          (1999 9:00 AM EDT)June 10;July 10
      #          (2000 9:00 AM EDT)June 10;July 10
      #          (2001 9:00 AM EDT)June 10;July 10
      #      Note: Since none of the BYDAY, BYMONTHDAY or BYYEARDAY components
      #      are specified, the day is gotten from DTSTART
      #
      #    Every other year on January, February, and March for 10 occurrences:
      #
      #      DTSTART;TZID=US-Eastern:19970310T090000
      #      RRULE:FREQ=YEARLY;INTERVAL=2;COUNT=10;BYMONTH=1,2,3
      #
      #      ==> (1997 9:00 AM EST)March 10
      #          (1999 9:00 AM EST)January 10;February 10;March 10
      #          (2001 9:00 AM EST)January 10;February 10;March 10
      #          (2003 9:00 AM EST)January 10;February 10;March 10
      #
      #    Every 3rd year on the 1st, 100th and 200th day for 10 occurrences:
      #
      #      DTSTART;TZID=US-Eastern:19970101T090000
      #      RRULE:FREQ=YEARLY;INTERVAL=3;COUNT=10;BYYEARDAY=1,100,200
      #
      #      ==> (1997 9:00 AM EST)January 1
      #          (1997 9:00 AM EDT)April 10;July 19
      #          (2000 9:00 AM EST)January 1
      #          (2000 9:00 AM EDT)April 9;July 18
      #          (2003 9:00 AM EST)January 1
      #          (2003 9:00 AM EDT)April 10;July 19
      #          (2006 9:00 AM EST)January 1
      #
      #    Every 20th Monday of the year, forever:
      #
      #      DTSTART;TZID=US-Eastern:19970519T090000
      #      RRULE:FREQ=YEARLY;BYDAY=20MO
      #
      #      ==> (1997 9:00 AM EDT)May 19
      #          (1998 9:00 AM EDT)May 18
      #          (1999 9:00 AM EDT)May 17
      #      ...
      #
      #    Monday of week number 20 (where the default start of the week is
      #    Monday), forever:
      #
      #      DTSTART;TZID=US-Eastern:19970512T090000
      #      RRULE:FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO
      #
      #      ==> (1997 9:00 AM EDT)May 12
      #          (1998 9:00 AM EDT)May 11
      #          (1999 9:00 AM EDT)May 17
      #      ...
      #
      #    Every Thursday in March, forever:
      #
      #      DTSTART;TZID=US-Eastern:19970313T090000
      #      RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=TH
      #
      #      ==> (1997 9:00 AM EST)March 13,20,27
      #          (1998 9:00 AM EST)March 5,12,19,26
      #          (1999 9:00 AM EST)March 4,11,18,25
      #      ...
      #
      #    Every Thursday, but only during June, July, and August, forever:
      #
      #      DTSTART;TZID=US-Eastern:19970605T090000
      #      RRULE:FREQ=YEARLY;BYDAY=TH;BYMONTH=6,7,8
      #
      #      ==> (1997 9:00 AM EDT)June 5,12,19,26;July 3,10,17,24,31;
      #                        August 7,14,21,28
      #          (1998 9:00 AM EDT)June 4,11,18,25;July 2,9,16,23,30;
      #                        August 6,13,20,27
      #          (1999 9:00 AM EDT)June 3,10,17,24;July 1,8,15,22,29;
      #                        August 5,12,19,26
      #      ...
      #
      #    Every Friday the 13th, forever:
      #
      #      DTSTART;TZID=US-Eastern:19970902T090000
      #      EXDATE;TZID=US-Eastern:19970902T090000
      #      RRULE:FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13
      #
      #      ==> (1998 9:00 AM EST)February 13;March 13;November 13
      #          (1999 9:00 AM EDT)August 13
      #          (2000 9:00 AM EDT)October 13
      #      ...
      #
      #    The first Saturday that follows the first Sunday of the month,
      #     forever:
      #
      #      DTSTART;TZID=US-Eastern:19970913T090000
      #      RRULE:FREQ=MONTHLY;BYDAY=SA;BYMONTHDAY=7,8,9,10,11,12,13
      #
      #      ==> (1997 9:00 AM EDT)September 13;October 11
      #          (1997 9:00 AM EST)November 8;December 13
      #          (1998 9:00 AM EST)January 10;February 7;March 7
      #          (1998 9:00 AM EDT)April 11;May 9;June 13...
      #      ...
      #
      #    Every four years, the first Tuesday after a Monday in November,
      #    forever (U.S. Presidential Election day):
      #
      #      DTSTART;TZID=US-Eastern:19961105T090000
      #      RRULE:FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYDAY=TU;BYMONTHDAY=2,3,4,
      #       5,6,7,8
      #
      #      ==> (1996 9:00 AM EST)November 5
      #          (2000 9:00 AM EST)November 7
      #          (2004 9:00 AM EST)November 2
      #      ...
      #
      #    The 3rd instance into the month of one of Tuesday, Wednesday or
      #    Thursday, for the next 3 months:
      #
      #      DTSTART;TZID=US-Eastern:19970904T090000
      #      RRULE:FREQ=MONTHLY;COUNT=3;BYDAY=TU,WE,TH;BYSETPOS=3
      #
      #      ==> (1997 9:00 AM EDT)September 4;October 7
      #          (1997 9:00 AM EST)November 6
      #
      #    The 2nd to last weekday of the month:
      #
      #      DTSTART;TZID=US-Eastern:19970929T090000
      #      RRULE:FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2
      #
      #      ==> (1997 9:00 AM EDT)September 29
      #          (1997 9:00 AM EST)October 30;November 27;December 30
      #          (1998 9:00 AM EST)January 29;February 26;March 30
      #      ...
      #
      #    Every 3 hours from 9:00 AM to 5:00 PM on a specific day:
      #
      #      DTSTART;TZID=US-Eastern:19970902T090000
      #      RRULE:FREQ=HOURLY;INTERVAL=3;UNTIL=19970902T170000Z
      #
      #      ==> (September 2, 1997 EDT)09:00,12:00,15:00
      #
      #    Every 15 minutes for 6 occurrences:
      #
      #      DTSTART;TZID=US-Eastern:19970902T090000
      #      RRULE:FREQ=MINUTELY;INTERVAL=15;COUNT=6
      #
      #      ==> (September 2, 1997 EDT)09:00,09:15,09:30,09:45,10:00,10:15
      #
      #    Every hour and a half for 4 occurrences:
      #
      #      DTSTART;TZID=US-Eastern:19970902T090000
      #      RRULE:FREQ=MINUTELY;INTERVAL=90;COUNT=4
      #
      #      ==> (September 2, 1997 EDT)09:00,10:30;12:00;13:30
      #
      #    Every 20 minutes from 9:00 AM to 4:40 PM every day:
      #
      #      DTSTART;TZID=US-Eastern:19970902T090000
      #      RRULE:FREQ=DAILY;BYHOUR=9,10,11,12,13,14,15,16;BYMINUTE=0,20,40
      #      or
      #      RRULE:FREQ=MINUTELY;INTERVAL=20;BYHOUR=9,10,11,12,13,14,15,16
      #
      #      ==> (September 2, 1997 EDT)9:00,9:20,9:40,10:00,10:20,
      #                                 ... 16:00,16:20,16:40
      #          (September 3, 1997 EDT)9:00,9:20,9:40,10:00,10:20,
      #                                ...16:00,16:20,16:40
      #      ...
      #
      #    An example where the days generated makes a difference because of
      #    WKST:
      #
      #      DTSTART;TZID=US-Eastern:19970805T090000
      #      RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=MO
      #
      #      ==> (1997 EDT)Aug 5,10,19,24
      #
      #      changing only WKST from MO to SU, yields different results...
      #
      #      DTSTART;TZID=US-Eastern:19970805T090000
      #      RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=SU
      #      ==> (1997 EDT)August 5,17,19,31
      #
      class RRULE < Base
      end

      ## 4.8.6 Alarm Component Properties

      # 4.8.6.1 Action
      #
      # Purpose: This property defines the action to be invoked when an alarm
      # is triggered.
      #
      # Value Type: TEXT
      #
      # Property Parameters: Non-standard property parameters can be
      # specified on this property.
      #
      # Conformance: This property MUST be specified once in a "VALARM"
      # calendar component.
      #
      # Description: Each "VALARM" calendar component has a particular type
      # of action associated with it. This property specifies the type of
      # action
      #
      # Format Definition: The property is defined by the following notation:
      #
      #      action     = "ACTION" actionparam ":" actionvalue CRLF
      #      actionparam        = *(";" xparam)
      #      actionvalue        = "AUDIO" / "DISPLAY" / "EMAIL" / "PROCEDURE"
      #                         / iana-token / x-name
      #
      # Example: The following are examples of this property in a "VALARM"
      # calendar component:
      #
      #      ACTION:AUDIO
      #      ACTION:DISPLAY
      #      ACTION:PROCEDURE
      #
      class ACTION < Base
      end

      # 4.8.6.2 Repeat Count
      #
      # Purpose: This property defines the number of time the alarm should be
      # repeated, after the initial trigger.
      #
      #    Value Type: INTEGER
      #
      # Property Parameters: Non-standard property parameters can be
      # specified on this property.
      #
      # Conformance: This property can be specified in a "VALARM" calendar
      # component.
      #
      # Description: If the alarm triggers more than once, then this property
      # MUST be specified along with the "DURATION" property.
      #
      # Format Definition: The property is defined by the following notation:
      #
      #      repeatcnt  = "REPEAT" repparam ":" integer CRLF
      #      ;Default is "0", zero.
      #
      #      repparam   = *(";" xparam)
      #
      # Example: The following is an example of this property for an alarm
      # that repeats 4 additional times with a 5 minute delay after the
      # initial triggering of the alarm:
      #
      #      REPEAT:4
      #      DURATION:PT5M
      #
      class REPEAT < Base
      end

      # 4.8.6.3 Trigger
      #
      # Purpose: This property specifies when an alarm will trigger.
      #
      # Value Type: The default value type is DURATION. The value type can be
      # set to a DATE-TIME value type, in which case the value MUST specify a
      # UTC formatted DATE-TIME value.
      #
      # Property Parameters: Non-standard, value data type, time zone
      # identifier or trigger relationship property parameters can be
      # specified on this property. The trigger relationship property
      # parameter MUST only be specified when the value type is DURATION.
      #
      # Conformance: This property MUST be specified in the "VALARM" calendar
      # component.
      #
      # Description: Within the "VALARM" calendar component, this property
      # defines when the alarm will trigger. The default value type is
      # DURATION, specifying a relative time for the trigger of the alarm.
      # The default duration is relative to the start of an event or to-do
      # that the alarm is associated with. The duration can be explicitly set
      # to trigger from either the end or the start of the associated event
      # or to-do with the "RELATED" parameter. A value of START will set the
      # alarm to trigger off the start of the associated event or to-do. A
      # value of END will set the alarm to trigger off the end of the
      # associated event or to-do.
      #
      # Either a positive or negative duration may be specified for the
      # "TRIGGER" property. An alarm with a positive duration is triggered
      # after the associated start or end of the event or to-do. An alarm
      # with a negative duration is triggered before the associated start or
      # end of the event or to-do.
      #
      # The "RELATED" property parameter is not valid if the value type of
      # the property is set to DATE-TIME (i.e., for an absolute date and time
      # alarm trigger). If a value type of DATE-TIME is specified, then the
      # property value MUST be specified in the UTC time format. If an
      # absolute trigger is specified on an alarm for a recurring event or
      # to-do, then the alarm will only trigger for the specified absolute
      # date/time, along with any specified repeating instances.
      #
      # If the trigger is set relative to START, then the "DTSTART" property
      # MUST be present in the associated "VEVENT" or "VTODO" calendar
      # component. If an alarm is specified for an event with the trigger set
      # relative to the END, then the "DTEND" property or the "DSTART" and
      # "DURATION' properties MUST be present in the associated "VEVENT"
      # calendar component. If the alarm is specified for a to-do with a
      # trigger set relative to the END, then either the "DUE" property or
      # the "DSTART" and "DURATION' properties MUST be present in the
      # associated "VTODO" calendar component.
      #
      # Alarms specified in an event or to-do which is defined in terms of a
      # DATE value type will be triggered relative to 00:00:00 UTC on the
      # specified date. For example, if "DTSTART:19980205, then the duration
      # trigger will be relative to19980205T000000Z.
      #
      # Format Definition: The property is defined by the following notation:
      #
      #      trigger    = "TRIGGER" (trigrel / trigabs)
      #      trigrel    = *(
      #                 ; the following are optional,
      #                 ; but MUST NOT occur more than once
      #                   (";" "VALUE" "=" "DURATION") /
      #                   (";" trigrelparam) /
      #                 ; the following is optional,
      #                 ; and MAY occur more than once
      #                   (";" xparam)
      #                   ) ":"  dur-value
      #      trigabs    = 1*(
      #                 ; the following is REQUIRED,
      #                 ; but MUST NOT occur more than once
      #                   (";" "VALUE" "=" "DATE-TIME") /
      #                 ; the following is optional,
      #                 ; and MAY occur more than once
      #                   (";" xparam)
      #                   ) ":" date-time
      #
      # Example: A trigger set 15 minutes prior to the start of the event or
      # to-do.
      #
      #      TRIGGER:-P15M
      #
      #    A trigger set 5 minutes after the end of the event or to-do.
      #
      #      TRIGGER;RELATED=END:P5M
      #
      #    A trigger set to an absolute date/time.
      #
      #      TRIGGER;VALUE=DATE-TIME:19980101T050000Z
      #
      class TRIGGER < Base
      end

      ## 4.8.7 Change Management Component Properties

      # 4.8.7.1 Date/Time Created
      #
      # Purpose: This property specifies the date and time that the calendar
      # information was created by the calendar user agent in the calendar
      # store.
      #
      # Note: This is analogous to the creation date and time for a file
      # in the file system.
      #
      #     Value Type: DATE-TIME
      #
      # Property Parameters: Non-standard property parameters can be
      # specified on this property.
      #
      # Conformance: The property can be specified once in "VEVENT", "VTODO"
      # or "VJOURNAL" calendar components.
      #
      # Description: The date and time is a UTC value.
      #
      # Format Definition: The property is defined by the following notation:
      #
      #      created    = "CREATED" creaparam ":" date-time CRLF
      #      creaparam  = *(";" xparam)
      #
      #    Example: The following is an example of this property:
      #
      #      CREATED:19960329T133000Z
      #
      class CREATED < Base
      end

      # 4.8.7.2 Date/Time Stamp
      #
      # Purpose: The property indicates the date/time that the instance of
      # the iCalendar object was created.
      #
      # Value Type: DATE-TIME
      #
      # Property Parameters: Non-standard property parameters can be
      # specified on this property.
      #
      # Conformance: This property MUST be included in the "VEVENT", "VTODO",
      # "VJOURNAL" or "VFREEBUSY" calendar components.
      #
      # Description: The value MUST be specified in the UTC time format.
      #
      # This property is also useful to protocols such as [IMIP] that have
      # inherent latency issues with the delivery of content. This property
      # will assist in the proper sequencing of messages containing iCalendar
      # objects.
      #
      # This property is different than the "CREATED" and "LAST-MODIFIED"
      # properties. These two properties are used to specify when the
      # particular calendar data in the calendar store was created and last
      # modified. This is different than when the iCalendar object
      # representation of the calendar service information was created or
      # last modified.
      #
      # Format Definition: The property is defined by the following notation:
      #
      #      dtstamp    = "DTSTAMP" stmparam ":" date-time CRLF
      #      stmparam   = *(";" xparam)
      #
      #    Example:
      #
      #      DTSTAMP:19971210T080000Z
      #
      class DTSTAMP < Base
      end

      # 4.8.7.3 Last Modified
      #
      #  Purpose: The property specifies the date and time that the
      #  information associated with the calendar component was last revised
      #  in the calendar store.
      #
      #       Note: This is analogous to the modification date and time for a
      #       file in the file system.
      #
      #    Value Type: DATE-TIME
      #
      # Property Parameters: Non-standard property parameters can be
      # specified on this property.
      #
      # Conformance: This property can be specified in the "EVENT", "VTODO",
      # "VJOURNAL" or "VTIMEZONE" calendar components.
      #
      # Description: The property value MUST be specified in the UTC time
      # format.
      #
      # Format Definition: The property is defined by the following notation:
      #
      #      last-mod   = "LAST-MODIFIED" lstparam ":" date-time CRLF
      #      lstparam   = *(";" xparam)
      #
      # Example: The following is are examples of this property:
      #
      #      LAST-MODIFIED:19960817T133000Z
      #
      class LAST_MODIFIED < Base
      end

      # 4.8.7.4 Sequence Number
      #
      # Purpose: This property defines the revision sequence number of the
      # calendar component within a sequence of revisions.
      #
      #    Value Type: integer
      #
      # Property Parameters: Non-standard property parameters can be
      # specified on this property.
      #
      # Conformance: The property can be specified in "VEVENT", "VTODO" or
      # "VJOURNAL" calendar component.
      #
      # Description: When a calendar component is created, its sequence
      # number is zero (US-ASCII decimal 48). It is monotonically incremented
      # by the "Organizer's" CUA each time the "Organizer" makes a
      # significant revision to the calendar component. When the "Organizer"
      # makes changes to one of the following properties, the sequence number
      # MUST be incremented:
      #
      #      .  "DTSTART"
      #      .  "DTEND"
      #      .  "DUE"
      #      .  "RDATE"
      #      .  "RRULE"
      #      .  "EXDATE"
      #      .  "EXRULE"
      #      .  "STATUS"
      #
      # In addition, changes made by the "Organizer" to other properties can
      # also force the sequence number to be incremented. The "Organizer" CUA
      # MUST increment the sequence number when ever it makes changes to
      # properties in the calendar component that the "Organizer" deems will
      # jeopardize the validity of the participation status of the
      # "Attendees". For example, changing the location of a meeting from one
      # locale to another distant locale could effectively impact the
      # participation status of the "Attendees".
      #
      # The "Organizer" includes this property in an iCalendar object that it
      # sends to an "Attendee" to specify the current version of the calendar
      # component.
      #
      # The "Attendee" includes this property in an iCalendar object that it
      # sends to the "Organizer" to specify the version of the calendar
      # component that the "Attendee" is referring to.
      #
      # A change to the sequence number is not the mechanism that an
      # "Organizer" uses to request a response from the "Attendees". The
      # "RSVP" parameter on the "ATTENDEE" property is used by the
      # "Organizer" to indicate that a response from the "Attendees" is
      # requested.
      #
      # Format Definition: This property is defined by the following
      # notation:
      #
      #      seq = "SEQUENCE" seqparam ":" integer CRLF
      #      ; Default is "0"
      #
      #      seqparam   = *(";" xparam)
      #
      # Example: The following is an example of this property for a calendar
      # component that was just created by the "Organizer".
      #
      #      SEQUENCE:0
      #
      # The following is an example of this property for a calendar component
      # that has been revised two different times by the "Organizer".
      #
      #      SEQUENCE:2
      #
      class SEQUENCE < Base
      end


      ## 4.8.8 Miscellaneous Component Properties

      # 4.8.8.1 Non-standard Properties
      #
      # Purpose: This class of property provides a framework for defining
      # non-standard properties.
      #
      #   Value Type: TEXT
      #
      # Property Parameters: Non-standard and language property parameters
      # can be specified on this property.
      #
      # Conformance: This property can be specified in any calendar
      # component.
      #
      # Description: The MIME Calendaring and Scheduling Content Type
      # provides a "standard mechanism for doing non-standard things". This
      # extension support is provided for implementers to "push the envelope"
      # on the existing version of the memo. Extension properties are
      # specified by property and/or property parameter names that have the
      # prefix text of "X-" (the two character sequence: LATIN CAPITAL LETTER
      # X character followed by the HYPEN-MINUS character). It is recommended
      # that vendors concatenate onto this sentinel another short prefix text
      # to identify the vendor. This will facilitate readability of the
      # extensions and minimize possible collision of names between different
      # vendors. User agents that support this content type are expected to
      # be able to parse the extension properties and property parameters but
      # can ignore them.
      #
      # At present, there is no registration authority for names of extension
      # properties and property parameters. The data type for this property
      # is TEXT. Optionally, the data type can be any of the other valid data
      # types.
      #
      # Format Definition: The property is defined by the following notation:
      #
      #      x-prop     = x-name *(";" xparam) [";" languageparam] ":" text CRLF
      #         ; Lines longer than 75 octets should be folded
      #
      # Example: The following might be the ABC vendor's extension for an
      # audio-clip form of subject property:
      #
      #      X-ABC-MMSUBJ;X-ABC-MMSUBJTYPE=wave:http://load.noise.org/mysubj.wav
      #
      class X_PROP < Base
      end


      # 4.8.8.2 Request Status
      #
      # Purpose: This property defines the status code returned for a
      # scheduling request.
      #
      # Value Type: TEXT
      #
      # Property Parameters: Non-standard and language property parameters
      # can be specified on this property.
      #
      # Conformance: The property can be specified in "VEVENT", "VTODO",
      # "VJOURNAL" or "VFREEBUSY" calendar component.
      #
      # Description: This property is used to return status code information
      # related to the processing of an associated iCalendar object. The data
      # type for this property is TEXT.
      #
      # The value consists of a short return status component, a longer
      # return status description component, and optionally a status-specific
      # data component. The components of the value are separated by the
      # SEMICOLON character (US-ASCII decimal 59).
      #
      # The short return status is a PERIOD character (US-ASCII decimal 46)
      # separated 3-tuple of integers. For example, "3.1.1". The successive
      # levels of integers provide for a successive level of status code
      # granularity.
      #
      # The following are initial classes for the return status code.
      # Individual iCalendar object methods will define specific return
      # status codes for these classes. In addition, other classes for the
      # return status code may be defined using the registration process
      # defined later in this memo.
      #
      #      |==============+===============================================|
      #      | Short Return | Longer Return Status Description              |
      #      | Status Code  |                                               |
      #      |==============+===============================================|
      #      |    1.xx      | Preliminary success. This class of status     |
      #      |              | of status code indicates that the request has |
      #      |              | request has been initially processed but that |
      #      |              | completion is pending.                        |
      #      |==============+===============================================|
      #      |    2.xx      | Successful. This class of status code         |
      #      |              | indicates that the request was completed      |
      #      |              | successfuly. However, the exact status code   |
      #      |              | can indicate that a fallback has been taken.  |
      #      |==============+===============================================|
      #      |    3.xx      | Client Error. This class of status code       |
      #      |              | indicates that the request was not successful.|
      #      |              | The error is the result of either a syntax or |
      #      |              | a semantic error in the client formatted      |
      #      |              | request. Request should not be retried until  |
      #      |              | the condition in the request is corrected.    |
      #      |==============+===============================================|
      #      |    4.xx      | Scheduling Error. This class of status code   |
      #      |              | indicates that the request was not successful.|
      #      |              | Some sort of error occurred within the        |
      #      |              | calendaring and scheduling service, not       |
      #      |              | directly related to the request itself.       |
      #      |==============+===============================================|
      #
      # Format Definition: The property is defined by the following notation:
      #
      #      rstatus    = "REQUEST-STATUS" rstatparam ":"
      #                   statcode ";" statdesc [";" extdata]
      #      rstatparam = *(
      #                 ; the following is optional,
      #                 ; but MUST NOT occur more than once
      #                 (";" languageparm) /
      #                 ; the following is optional,
      #                 ; and MAY occur more than once
      #                 (";" xparam)
      #                 )
      #
      #      statcode   = 1*DIGIT *("." 1*DIGIT)
      #      ;Hierarchical, numeric return status code
      #
      #      statdesc   = text
      #      ;Textual status description
      #
      #      extdata    = text
      #      ;Textual exception data. For example, the offending property
      #      ;name and value or complete property line.
      #
      # Example: The following are some possible examples of this property.
      # The COMMA and SEMICOLON separator characters in the property value
      # are BACKSLASH character escaped because they appear in a  text value.
      #
      #      REQUEST-STATUS:2.0;Success
      #
      #      REQUEST-STATUS:3.1;Invalid property value;DTSTART:96-Apr-01
      #
      #      REQUEST-STATUS:2.8; Success\, repeating event ignored. Scheduled
      #       as a single event.;RRULE:FREQ=WEEKLY\;INTERVAL=2
      #
      #      REQUEST-STATUS:4.1;Event conflict. Date/time is busy.
      #
      #      REQUEST-STATUS:3.7;Invalid calendar user;ATTENDEE:
      #       MAILTO:jsmith@host.com
      #
      class REQUEST_STATUS < Base
      end
    end # module Property
  end # ICalendar
end # module Mhc
