### mhc/signal.rb
##
## Author:  Yoshinari Nomura <nom@quickhack.net>
##
## Created: 1999/07/16
## Revised: $Date: 2001/03/13 07:01:25 $
##

module Mhc
  class SignalConduit
    def initialize
      @proc_table = {}
      @descriptor = 0
    end

    def signal_emit(sig, *arg)
      return nil if @proc_table[sig].nil?

      @proc_table[sig].keys.sort.each do |descriptor|
        @proc_table[sig][descriptor].call(*arg)
      end
    end

    def signal_connect(sig, &proc)
      @descriptor += 1
      @proc_table[sig] ||= {}
      @proc_table[sig][@descriptor] = proc
      return @descriptor
    end

    def signal_disconnect(descriptor)
      @proc_table.each_key do |sig|
        @proc_table[sig].delete(descriptor)
      end
    end

    def dump
      @proc_table.each_key do |sig|
        print "(#{self}) #{sig} -> "
        @proc_table[sig].keys.sort.each do |descriptor|
          print @proc_table[sig][descriptor], " "
        end
        print "\n"
      end
    end
  end # class SignalConduit

  class Ticker < SignalConduit
    def initialize
      super
      @now = ::Time.now.localtime
      @thread  = Thread.new do
        while true
          tick
          sleep 10 # time resolution in second.
        end
      end
      @thread.abort_on_exception= true
    end

    def tick
      now = ::Time.now.localtime

      signal_emit('sec-changed') if (now != @now)
      signal_emit('day-changed') if (now.day != @now.day)
      signal_emit('min-changed') if (now.min != @now.min) 
      signal_emit('month-changed') if (now.month != @now.month)

      @now = now
    end

  end # class Ticker
end # module Mhc

### Copyright Notice:

## Copyright (C) 1999, 2000 Yoshinari Nomura. All rights reserved.
## Copyright (C) 2000 MHC developing team. All rights reserved.

## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions
## are met:
## 
## 1. Redistributions of source code must retain the above copyright
##    notice, this list of conditions and the following disclaimer.
## 2. Redistributions in binary form must reproduce the above copyright
##    notice, this list of conditions and the following disclaimer in the
##    documentation and/or other materials provided with the distribution.
## 3. Neither the name of the team nor the names of its contributors
##    may be used to endorse or promote products derived from this software
##    without specific prior written permission.
## 
## THIS SOFTWARE IS PROVIDED BY THE TEAM AND CONTRIBUTORS ``AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
## LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
## FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
## THE TEAM OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
## INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
## (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
## HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
## STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
## OF THE POSSIBILITY OF SUCH DAMAGE.

### mhc/signal.rb ends here
