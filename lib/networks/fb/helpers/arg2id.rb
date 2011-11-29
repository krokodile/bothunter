module Fb
  def self.arg2id arg, username = false
    case arg.to_s
    when /^(\d+)$/
      id = $1
    when /^.*\/(\d+)$/
      id = $1
    when /^.*\/([a-zA-Z0-9\.]+)$/
      id = $1
    when /^([a-zA-Z0-9\.]+)$/
      id = $1
    end

    if username.present?
      ::Fb::API.explorer(id)['username']
    else
      ::Fb::API.explorer(id)['id']
    end
  end
end
