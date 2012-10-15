module Mhc
  class DataStore
    HOME            = ENV['HOME'] || ''
    DEFAULT_BASEDIR = HOME + '/Mail/schedule'
    DEFAULT_RCFILE  = HOME + '/.schedule'

    UID_DIRECTORY   = "/.mhc_db"
    LOG_FILENAME    = UID_DIRECTORY + "/mhc-db-log"
    UID_FILENAME    = UID_DIRECTORY + "/mhc-db-log"

    def initialize(basedir = DEFAULT_BASEDIR, rcfile = DEFAULT_RCFILE)
      @basedir   = Pathname.new(basedir)
      @rcfile    = Pathname.new(rcfile)

      @slot_top  = @basedir
      @uid_top   = @basedir + "db/uid"
      @logfile   = @basedir + 'db/mhc-db-transaction.log'
    end

    def store(uid, slot, data)
      path = new_path_in_slot(slot)
      store_data(path, data)
      store_uid(uid, path)
    end

    def find_by_uid(uid)
      File.open(find_path(uid), "r") do |file|
        data = file.read
      end
      return data
    end

    def delete(uid)
      find_path(uid)
    end

    private

    def store_data(path, data)
      File.open(path, "w") do |file|
        file.write(data)
      end
    end

    def store_uid(uid, path)
      File.open(@uid_top + uid, "w") do |file|
        file.write(path)
      end
    end

    def find_path(uid)
      File.open(@uid_top + uid, "r") do |file|
        slot_path = file.read
      end
      return slot_path
    end

    def uid_to_path(uid)
      return @uid_pool + uid
    end

    def slot_to_path(uid)
      return @slot_pool + slot
    end

    def new_path_in_slot(slot)
      return nil if !makedir_or_higher(slot)
      new = 1
      Dir.open(slot).each do |file|
        if (file =~ /^\d+$/)
          num = file.to_i
          new = num + 1 if new <= num
        end
      end
      return slot + '/' + new.to_s
    end

    def makedir_or_higher(dir)
      return true if File.directory?(dir)
      parent = File.dirname(dir)
      if makedir_or_higher(parent)
        Dir.mkdir(dir)
        File.open(dir, "r") {|f| f.sync} if File.method_defined?("fsync")
        return true
      end
      return false
    end
  end # class DataStore
end # module Mhc
