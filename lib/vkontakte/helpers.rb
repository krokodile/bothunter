module Vk
  module Helpers
    def self.parse_gid url
      return url if url.is_a?(Fixnum)

      url = url.to_s

      if url =~ /^([0-9]+)$/
        $1
      elsif url =~ /.*\/?.*([0-9]+)$/
        $1
      elsif url =~ /.*\/(.*)/
        $1
      else
        url
      end
    end

    def self.is_gid? gid
      gid.to_s =~ /^\d+$/
    end

    def self.parse_uid url
      return url if url.is_a?(Fixnum)

      case user.to_s
      when /^\?([0-9]+)$/
        $1
      when /^\/?id([0-9]+)$/
        $1
      when /^.*\/id([0-9]+)$/
        $1
      when /^\/?([0-9a-zA-Z\-\_\.]+)$/
        $1
      end
    end

    def self.is_uid? uid
      uid.to_s =~ /^\d+$/
    end
  end
end
