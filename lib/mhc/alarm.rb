## MHC Alarm クラス
##
## MHC Alarm クラスは、MhcScheduleDB から、先の予定をスキャンしてきて、
## Alarm を発行してほしい時間順にソートした配列を保存しておく。予定時
## 間が来たら、signal を発行する。
##
## 何者かによって、DB が変更されたら、保存している Alarm 情報が無効に
## なってしまうので、再スキャンする。
##
## 1. make_alarm_table : @alarm_table へ予定表の保存
##
##    今日の日付から、LOOK_AHEAD_DAYS 日分先の予定を scan, sort する
##
##    aTime はアラーム発行時間 (予定の時間ではない)
##    xTime を予定の時間だとすると、
##
##    now   <= aTime <= xTime  な予定 --> @alarm_table に保存
##    aTime <= now   <= xTime  な予定 --> 即 signal を発行
##    aTime <= xTime <= now    な予定 --> 捨てる
## 
##    @alarm_table =  [[aTime, aMhc::ScheduleItem], ... ]
##
##
## 2. スケジュールが何者かによって変更されてしまったとき
##
##    DB から updated signal を拾って、1 を実行する。そのとき、
##
##    > aTime <= now   <= xTime  な予定 --> 即 signal を発行
##
##    は実行しない。
##
## 3. 1分ごとに、
##
##    a. @alarm_table の先頭と現在時刻 now を比較
##    b. aTime <= now なら signal を emit。@alarm_table から捨てて a. に戻る
##
## 4. 1日毎に、
##
##    日が変わる毎に、最後に scan した日付の 1日先の内容を
##    1. の方法で @alarm_table に追加。
##

module Mhc
  class Alarm
    LOOK_AHEAD_DAYS   = 100

    def initialize(db = MhcScheduleDB.new)
      @db          = db
      @date_begin  = nil
      @sig_conduit = Ticker.new
      @alarm_table = []

      @sig_conduit.signal_connect('min-changed') do
        make_alarm_table(Mhc::Date.new, LOOK_AHEAD_DAYS, false)
        check_alarm_table
      end

      @sig_conduit.signal_connect('day-changed') do
        update_alarm_table
      end

      make_alarm_table(Mhc::Date.new, LOOK_AHEAD_DAYS, true)
    end

    def signal_connect(sig, &p)
      @sig_conduit.signal_connect(sig, &p)
    end

    def check
      check_alarm_table
    end

    ## for debug
    def dump
      @alarm_table.each do |x|
        atime, sch = x
        print "#{atime} #{sch.subject}\n"
      end
    end

    ################################################################
    private

    ## invoked when initialize and rescan.
    def make_alarm_table(date_begin, ahead_days, is_initialize = false)
      @date_begin  = date_begin
      now          = ::Time.now

      for i in 1 .. ahead_days
        @db.search1(@date_begin).each do |sch|
          next if !sch.alarm
          xtime = @date_begin.to_t(sch.time_b || Mhc::Time.new(0, 0))
          atime = xtime - sch.alarm

          if now <= atime
            @alarm_table << [atime, sch]
          elsif now <= xtime && is_initialize
            @alarm_table << [atime, sch]
          end
        end
        @date_begin = @date_begin.succ
      end
      @alarm_table.sort!{|a, b| a[0] <=> b[0]} if @alarm_table
    end

    def check_alarm_table
      now = ::Time.now

      while @alarm_table[0] && @alarm_table[0][0] <= now
        atime, sch = @alarm_table.shift
        xdate = time_to_date(atime + sch.alarm)
        @sig_conduit.signal_emit('time-arrived', xdate , sch)
      end
    end

    def update_alarm_table
      shortage = Mhc::Date.new - @date_begin + LOOK_AHEAD_DAYS

      if shortage > 0
        make_alarm_table(@date_begin, shortage)
      end
    end

    def time_to_date(time)
      return Mhc::Date.new(*time.to_a.indexes(5, 4, 3))
    end

  end # class Alarm
end # module Mhc
