module Codesake
  module Commons
    class Io
      def self.remove_pid_file(pid_file)
        File.delete(pid_file) if File.exists?(pid_file)
      end

      def self.create_pid_file(pid_file)
        f = File.new(pid_file, "w") 
        f.write("#{Process.pid}")
        f.close
      end

      def self.read_pid_file(pid_file)
        f = File.new(pid_file, "r")
        pid=f.read
        f.close
        pid
      end
    end
  end
end
