require 'rainbow'
require 'syslog'
require 'singleton'

module Codesake
  module Commons
    class Logging
      include Singleton

      attr_reader :silencer
      attr_reader :verbose
      attr_reader :syslog
      attr_accessor :filename

      def initialize
        super
        @silencer = false
        @verbose  = true
        @syslog   = true
        @filename = nil
      end

      def die(msg, pid_file=nil)
        STDERR.printf "#{Time.now.strftime("%H:%M:%S")} [!] #{msg}\n".color(:red)
        send_to_syslog(msg, :helo)
        send_to_file(msg, :helo)
        Codesake::Commons::Io.remove_pid_file(pid_file) unless pid_file.nil?
        Kernel.exit(-1)
      end

      def err(msg)
        STDERR.printf "#{Time.now.strftime("%H:%M:%S")} [!] #{msg}\n".color(:red)
        send_to_syslog(msg, :err)
        send_to_file(msg, :err)
      end

      def warn(msg)
        STDOUT.printf "#{Time.now.strftime("%H:%M:%S")} [!] #{msg}\n".color(:yellow)
        send_to_syslog(msg, :warn)
        send_to_file(msg, :warn)
      end

      def ok(msg)
        STDOUT.printf "#{Time.now.strftime("%H:%M:%S")} [*] #{msg}\n".color(:green)
        send_to_syslog(msg, :log)
        send_to_file(msg, :log)
      end

      def log(msg)
        return if @silencer
        STDOUT.printf "#{Time.now.strftime("%H:%M:%S")}: #{msg}\n".color(:white)
        send_to_syslog(msg, :debug)
        send_to_file(msg, :debug)
      end

      def helo(msg, pid_file = nil)
        STDOUT.printf "[*] #{msg} at #{Time.now.strftime("%H:%M:%S")}\n".color(:white)
        send_to_syslog(msg, :helo)
        send_to_file(msg, :helo)
        Codesake::Commons::Io.create_pid_file(pid_file) unless pid_file.nil?
      end

      def toggle_silence
        @silencer = ! @silencer
        @verbose  = ! @silencer
      end

      def toggle_syslog
        @syslog   = ! @syslog
        warn("codesake messages to syslog are now disabled") unless @syslog
        ok("codesake messages to syslog are now enabled") if @syslog
      end

      private
      def send_to_file(msg, level) 
        return false if @filename.nil?
        f = File.open(@filename, "a")
        f.write("#{Time.now.strftime("[%d/%m/%Y %H:%M:%S]")} - #{level.to_s} - #{msg}\n")
        f.close
      end

      def send_to_syslog(msg, level)
        return false unless @syslog

        log = Syslog.open("codesake") unless Syslog.opened?
        log = Syslog.reopen("codesake") if Syslog.opened?
        log.debug(msg.to_s)  if level == :debug
        log.warn(msg.to_s)   if level == :warn
        log.info(msg.to_s)   if level == :helo
        log.notice(msg.to_s) if level == :log
        log.err(msg.to_s)    if level == :error 
          
        true
      end
          
    end

  end
end
