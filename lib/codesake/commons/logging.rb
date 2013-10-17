require 'rainbow'
require 'syslog'
require 'singleton'

module Codesake
  module Commons
    class Logging
      include Singleton

      attr_reader   :silencer
      attr_reader   :verbose
      attr_reader   :syslog
      attr_accessor :filename
      attr_reader   :component

      def initialize
        super
        @silencer = false
        @verbose  = true
        @syslog   = true
        @filename = nil
        @component = ""
      end

      def die(msg, pid_file=nil)
        STDERR.print "#{Time.now.strftime("%H:%M:%S")} [!] #{@component}: #{msg}\n".color(:red)
        send_to_syslog(msg, :helo)
        send_to_file(msg, :helo)
        Codesake::Commons::Io.remove_pid_file(pid_file) unless pid_file.nil?
        Kernel.exit(-1)
      end

      def err(msg)
        STDERR.print "#{Time.now.strftime("%H:%M:%S")} [!] #{@component}: #{msg}\n".color(:red)
        send_to_syslog(msg, :err)
        send_to_file(msg, :err)
      end

      def warn(msg)
        STDOUT.print "#{Time.now.strftime("%H:%M:%S")} [!] #{@component}: #{msg}\n".color(:yellow)
        send_to_syslog(msg, :warn)
        send_to_file(msg, :warn)
      end

      def ok(msg)
        STDOUT.print "#{Time.now.strftime("%H:%M:%S")} [*] #{@component}: #{msg}\n".color(:green)
        send_to_syslog(msg, :log)
        send_to_file(msg, :log)
      end

      def log(msg)
        return if @silencer
        STDOUT.print "#{Time.now.strftime("%H:%M:%S")} [$] #{@component}: #{msg}\n".color(:white)
        send_to_syslog(msg, :log)
        send_to_file(msg, :log)
      end

      def helo(component, version, pid_file = nil)
        @component = component
        STDOUT.print "#{Time.now.strftime("%H:%M:%S")} [*] #{@component} v#{version} is starting up\n".color(:white)
        send_to_syslog("#{@component} v#{version} is starting up", :helo)
        send_to_file("#{@component} v#{version} is starting up", :helo)
        Codesake::Commons::Io.create_pid_file(pid_file) unless pid_file.nil?
      end

      def bye(pid_file = nil)
        STDOUT.print "#{Time.now.strftime("%H:%M:%S")} [*] #{@component} is leaving\n".color(:white)
        send_to_syslog("#{@component} is leaving", :helo)
        send_to_file("#{@component} is leaving", :helo)
        Codesake::Commons::Io.remove_pid_file(pid_file) unless pid_file.nil?
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
        return false if msg.nil? || msg.empty?

        log = Syslog.open("codesake") unless Syslog.opened?
        log = Syslog.reopen("codesake") if Syslog.opened?
        log.log(Syslog::LOG_DEBUG, msg.to_s)  if level == :debug
        log.log(Syslog::LOG_WARNING, msg.to_s)   if level == :warn
        log.log(Syslog::LOG_INFO, msg.to_s)   if level == :helo
        log.log(Syslog::LOG_INFO, msg.to_s) if level == :log
        log.log(Syslog::LOG_ERR, msg.to_s)    if level == :error 
          
        true
      end
          
    end

  end
end
