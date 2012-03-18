module Vk
  module Helpers
    def self.parse_gid url
      if url =~ /.*\/?.*([0-9]+)$/
        $1
      elsif url =~ /.*\/(.*)/
        $1
      else
        url
      end
    end
  end
end
