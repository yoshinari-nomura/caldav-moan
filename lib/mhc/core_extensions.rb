class Date
  #
  # Make a date by DAY like ``1st Wed of Nov, 1999''.
  # caller must make sure:
  #   YEAR and MONTH must be valid.
  #   NTH must be <0 or >0.
  #   WDAY must be 0..6.
  #
  # returns nil if no date was match (for example, 
  # no 5th Saturday exists on April 2010).
  #
  def self.new_by_day(year, month, nth, wday)
    direction = nth > 0 ? 1 : -1

    edge      = Date.new(year, month,  direction)
    y_offset  = nth - direction
    x_offset  = wday_difference(edge.wday, wday, direction)
    mday      = edge.mday + y_offset * 7 + x_offset

    if 1 <= mday && mday <= edge.mday
      return new(year, month, mday) 
    else
      return nil
    end
  end

  def next_monthday(month, mday)
    year = self.year + (month < self.month ? 1 : 0)
    return self.class.new(year, month, mday)
  end

  def next_day(month, nth, wday)
    year = self.year + (month < self.month ? 1 : 0)
    year += 1 while !(date = self.class.new_by_day(year, month, nth, wday))
    return date
  end


  private
  #
  # Returns diff of days between 2 wdays: FROM and TO.
  # Each FROM and TO is one of 0(=Sun) ... 6(Sat).
  #
  # DIRECTION must be -1 or 1, which represents search direction.
  #
  #     Sun Mon Tue Wed Thu Fri Sat Sun Mon Tue ...
  #      0   1   2   3   4   5   6   0   1   2  ...
  #
  # returns  3 if FROM, TO, DIRECTION = 4, 0,  1
  # returns -4 if FROM, TO, DIRECTION = 4, 0, -1
  # 
  def wday_difference(from, to, direction)
    return direction * ((direction * (to - from)) % 7)
  end
end
