# Class for generating headers for credential items.
#
class ServiceHeaders
  class << self
    
    # Add child class to global classes.
    # Child class name should look like `VkontakteHeaders`.
    #
    def inherited klass
      @@klasses ||= {}

      if klass.name =~ /^(\w+)Headers$/
        @@klasses[$1.downcase.to_sym] = klass
      end
    end
  
    # Generate item headers for service `service` with kind `kind`.
    # 
    # @param [Symbol] service
    #   name of service. This can be `:vkontakte` or `:facebook`.
    # @param [Symbol] kind
    #   kind of item. This can be `:accounts` or `:apps`.
    # @param [Hash] item
    #   item with credentials info as hash.
    #
    # @return [Hash]
    #   headers for RestClient or something like that.
    #
    def for service, kind, item
      @@klasses ||= {}
      
      if @@klasses[service.to_sym].is_a? Class
        @@klasses[service.to_sym].send kind.to_sym, item
      else
        {}
      end
    end
    
    # Check item for valid.
    #
    # @param [Symbol] service
    #   name of service. This can be `:vkontakte` or `:facebook`.
    # @param [Symbol] kind
    #   kind of item. This can be `:accounts` or `:apps`.
    # @param [Hash] item
    #   item with credentials info as hash.
    #
    # @return [Boolean]
    #   validation result.
    #
    def valid_item? service, kind, item
      @@klasses ||= {}
      
      if @@klasses[service.to_sym].is_a? Class
        @@klasses[service.to_sym].valid? kind.to_sym, item
      else
        false
      end
    end
  end
end
