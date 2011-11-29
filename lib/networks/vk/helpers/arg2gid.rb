module Vk
  def self.arg2gid group
    case group.to_s
    when /^\?([0-9]+)$/
      $1
    when /^\/?club([0-9]+)$/
      $1
    when /^.*\/club([0-9]+)$/
      $1
    when /^\/?([0-9a-zA-Z\-\_\.]+)$/
      $1
    end
  end

  def self.gid? group
    group.to_s =~ /^\d+$/
  end
end
