require 'mechanize'
require 'codesake/commons/logging'

module Codesake
  module Core
    class Target
      attr_reader :url
      attr_reader :username
      attr_reader :password
      
      attr_reader :page


      # This will be fed by codesake-gengiscan
      attr_reader :webserver
      attr_reader :language
      attr_reader :cms

      # This is the website tree. Fed by codesake-links. 
      # Each tree element is an hash like
      # {:url, :code, :kind, :dynamic} :dynamic is true or false if the page
      # has some dynamic content that needs to be exploited (url parameters,
      # forms, ...)
      attr_reader :site_tree

      attr_reader :cookies

      attr_reader :score
      attr_reader :vulns

      def initialize(options={})
        $logger = Codesake::Commons::Logging.instance
        @agent  = Mechanize.new
        @page   = nil

        @url      ||= options[:url]
        @username ||= options[:username]
        @password ||= options[:password]
      end

      def has_page?
        ! @page.nil?
      end

      def get_page(url = nil)
        url = @url if url.nil?

        begin
          @page = @agent.get(url)
          @cookies = @agent.cookies
        rescue => e
          $logger.err "get_page(): #{e.message}"
          @page = nil
        end

        @page
      end

      def is_alive?
        return false unless url
        return false unless @agent

        begin
          @agent.get('/')
          return true
        rescue Net::HTTP::Persistent::Error=>e
          return false
        end
      end
    end
  end
end
