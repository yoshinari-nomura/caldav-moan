# -*- ruby -*-

### mhc/utils.rb
##
## Author:  MIYOSHI Masanori <miyoshi@quickhack.net>
## Author:  Yoshinari Nomura <nom@quickhack.net>
##
##

require 'kconv'
require "pathname"

module Mhc
  class WorkingDirectoryManager
    def initialize(home_path = "/")
      @home_path = Pathname.new(home_path)
      raise "Home dir should be absolute path." unless @home_path.absolute?
      @cwd = @home_path
    end

    def chdir(path = nil)
      @cwd = (@cwd + (path || @home_path)).cleanpath
      return self
    end

    def pwd
      @cwd.to_s
    end

    alias_method :to_s, :pwd

    def relative_path_from_home(path)
      return path.relative_path_from(@home_path)
    end

    def descendant_of_home?
      rel = @cwd.relative_path_from(@home_path).to_s
      return false if rel == ".." || rel =~ /^\.\.\//
      return true
    end
  end
end

module Mhc
  
end

module Mhc
  module Kconv
    env = ENV['LC_ALL'] || ENV['LC_CTYPE'] || ENV['LANG']
    if env =~ /euc/i
      DISP_CODE = ::Kconv::EUC
    elsif env =~ /sjis|shift_jis/i
      DISP_CODE = ::Kconv::SJIS
    else
      DISP_CODE = ::Kconv::UTF8
    end

    def todisp(string)
      ::Kconv::kconv(string, DISP_CODE, ::Kconv::AUTO)
    end
    module_function :todisp

    def tomail(string)
      ::Kconv::tojis(string)
    end
    module_function :tomail

    def tohtml(string)
      ::Kconv::tojis(string)
    end
    module_function :tohtml

    def tops(string)
      ::Kconv::toeuc(string)
    end
    module_function :tops
  end
end

### Copyright Notice:

## Copyright (C) 2000 MHC developing team. All rights reserved.
## All rights reserved.

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
## THIS SOFTWARE IS PROVIDED BY Yoshinari Nomura AND CONTRIBUTORS ``AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
## LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
## FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
## Yoshinari Nomura OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
## INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
## (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
## HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
## STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
## OF THE POSSIBILITY OF SUCH DAMAGE.

### mhc/utils.rb ends here
