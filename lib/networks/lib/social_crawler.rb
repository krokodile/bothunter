class SocialCrawler
  attr_reader :uri

  class << self
    def parse network, kind, *args
      kind = kind.downcase

      case kind
      when :group
        case network
        when :vkontakte
          SocialNetwork.vkontakte.parse_group *args
        end
      else
        raise ArgumentError, "Unknown value for argument 'kind': #{kind}"
      end
    end
  end
end

