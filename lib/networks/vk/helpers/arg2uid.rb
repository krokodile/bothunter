module Vk
  def self.arg2uid user
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
  
  def self.uid? user
    user.to_s =~ /^\d+$/
  end
end
