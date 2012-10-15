
################################################################
## helper classes

module Mhc
  module ICalendar
    class Logging
      def initialize(filename = 'icalendar-debug.log')
        @log = File.open(filename, "a")
        @is_logging = true
      end

      def print(*string)
        @log.print(*string) if @is_logging
      end

      def on
        @is_logging = true
        return self
      end

      def off
        @is_logging = false
        return self
      end
    end
  end
end

################################################################
## monkey patches

class String
  def unquote
    self.sub(/^"/, '').sub(/"$/, '')
  end

  def unfold
    self.gsub(/\r?\n[\s\t]/, '')
  end

  ## for text property
  def unescape
    self.gsub(/\\(.)/) do
      ($1 == 'n' or $1 == 'N') ? "\n" : $1
    end
  end

  ## for text property
  def escape
    # \ ; , LF  -> \\ \; \, \n
    self.gsub(/([\\;,\n])/) do
      $1 == "\n" ? "\\n" : "\\#{$1}"
    end
  end
end
