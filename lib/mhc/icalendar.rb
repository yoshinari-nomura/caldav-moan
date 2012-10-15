
require File.dirname(__FILE__) + '/icalendar/helper'
require File.dirname(__FILE__) + '/icalendar/property-value'
require File.dirname(__FILE__) + '/icalendar/property'
require File.dirname(__FILE__) + '/icalendar/contentline'
require File.dirname(__FILE__) + '/icalendar/component'

##
## 4.6.1 Event Component
##
##   Component Name: "VEVENT"
##
##   Purpose: Provide a grouping of component properties that describe
##   an event.
##
##   Format Definition: A "VEVENT" calendar component is defined by
##   the following notation:
##
##   eventc = "BEGIN" ":" "VEVENT" CRLF
##              eventprop *alarmc
##              "END" ":" "VEVENT" CRLF
##
## 通常，Opaque と扱われるカレンダ上の時間の幅を指定します．
##
## DTSTART は通常 DATE-TIME 型を持ちますが，
## DATE 型を指定することによって，リマインダや
## 記念日などの全日イベントを指定できます．
##
## DTSTART が DATE 型を持つ場合は，DTEND も DATE 型でなければいけません．
##
## DTSTART はイベントの開始時刻を示します．
## 繰り返しイベントに対しては，繰り返しの最初のイベントを指定する役目
## もあります．
##
## DTEND は，終了時刻を指定しますが，その時刻を含みません．
##
## DTSTART が DATE 型で，DTEND が指定されていない場合は，
## そのイベントの時間範囲は，DTSTART が示す全日となります．
##
## DTSTART が DATE-TIME 型で，DTEND が指定されていない場合は，
## そのイベントの時間範囲は 0 です．
##
## VEVENT は他のコンポーネントとネストすることはできませんが，
## RELATED-TO プロパティを使って，VEVENT, VTODO, VJOURNAL と関連を
## 持たせることができます．
#
# 日時に関する Property:
#
# 5055: DTEND := DATE-TIME | DATE
# 5174: DTSTART := DATE-TIME | DATE
# 5241: DURATION :=
# 5975: RECURRENCE-ID
# 6073: RELATED-TO
#       RELATED-TO;RELTYPE=SIBLING:<19960401...@host.com>
#              (1534: RELTYPE)
# 6190: UID
# 6268: EXDATE
# 6353: EXRULE
# 6422: RDATE (RRULE と併用して，X-SC-Date: 2番目以降に相当)
#       6507 RDATE;VALUE=PERIOD:19960403T020000Z/19960403T040000Z,
#       6508                                19960404T010000Z/PT3H
# 6515: RRULE
#
# 同期に必要そうなタイムスタンプ系:
#
# 7214:   CREATED        # スケジュール帳での作成日時
# 7253:   DTSTAMP        # icalender 形式自身の作成日時
# 7299:   LAST-MODIFIED  # スケジュール帳での変更日時
# 7331:   SEQUENCE       # 以下を書換えるたびに +1 する
#
################################################################
## parameters from rfc2445
##
## ALTREP         = " URI "  alternete description for Text v
## CN             = Text w/CAL-ADDRESS v
## CUTYPE         = (INDIVIDUAL|GROUP|RESOURCE|ROOM|UNKNOWN) w/CAL-ADDRESS v
##* DELEGATED-FROM = "cal-address" (, "cal-address")*   w/CAL-ADDRESS v
##* DELEGATED-TO   = "cal-address" (, "cal-address")*   w/CAL-ADDRESS v
## DIR            = " URI "  w/CAL-ADDRESS v
## ENCODING       = (8BIT|BASE64)   BINARY v must use BASE64
## FMTTYPE        = IANA-registered-content-type usuary use with ATTACH p
## FBTYPE         = (FREE|BUSY|BUSY-UNAVAILABLE|BUSY-TENTATIVE)
## LANGUAGE       = <Text identifying a language as defined in [RFC 1766]>
##* MEMBER         = "cal-address" (, "cal-address")*   w/CAL-ADDRESS v
## PARTSTAT       = (NEEDS-ACTION|ACCEPTED|DECLINED|TENTATIVE|DELEGATED)
##                   VEVENT
##                  (NEEDS-ACTION|ACCEPTED|DECLINED|TENTATIVE|DELEGATED|
##                   COMPLETED|IN-PROCESS) VTODO
##                  (NEEDS-ACTION|ACCEPTED|DECLINED) VJOURNAL
## RANGE          = (THISANDPRIOR|THISANDFUTURE) for rrule
## RELATED        = (START|END) for TRIGGER in VALARM
## RELTYPE        = (PARENT|CHILD|SIBLING) for RELATED-TO
## ROLE           = (CHAIR|REQ-PARTICIPANT|OPT-PARTICIPANT|NON-PARTICIPANT)
##                   default is REQ-PARTICIPANT
## RSVP           = (TRUE|FALSE)
## SENT-BY        = "cal-address"
## TZID           = [/] timezone-id
## VALUE          = (BINARY|BOOLEAN|CAL-ADDRESS|DATE|
##                   DATE-TIME|DURATION|FLOAT|INTEGER|PERIOD|RECUR|
##                   TEXT|TIME|URI|UTC-OFFSET) must be of a single valuetype.
## TZID:
##   Description: The parameter MUST be specified on the "DTSTART",
## "DTEND", "DUE", "EXDATE" and "RDATE" properties when either a DATE-
## TIME or TIME value type is specified and when the value is not either
## a UTC or a "floating" time. Refer to the DATE-TIME or TIME value type
## definition for a description of UTC and "floating time" formats. This
## property parameter specifies a text value which uniquely identifies
## the "VTIMEZONE" calendar component to be used when evaluating the
## time portion of the property. The value of the TZID property
## parameter will be equal to the value of the TZID property for the
## matching time zone definition. An individual "VTIMEZONE" calendar
## component MUST be specified for each unique "TZID" parameter value
## specified in the iCalendar object.

################################################################
module Mhc
  module ICalendar
  end # module ICalendar
end # module Mhc

if $0 == __FILE__
  fields = []
  $log = Mhc::ICalendar::Logging.new.on
  lines = gets(nil).unfold.split(/\r?\n/)
  lines.shift # eat first 'VCALENDAR'
  Mhc::ICalendar::Component::VCALENDAR.parse(lines, 'VCALENDAR')
end
