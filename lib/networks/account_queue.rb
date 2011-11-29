# Credential items manager and queue.
#
# == Example for {http://vk.com Vkontakte}
# Get an available account credentials:
#   puts AccountQueue.next :vkontakte, :account # => { username: 'User1', password: 'pswd' }
# Get an available application credentials:
#   puts AccountQueue.next :vkontakte, :apps # => { id: '21324', secret: '45s43qse' }
#
# @see VkontakteHeaders
#
module AccountQueue
  
  # Initialize accounts queue.
  #
  def self.initialize_queue!
    #TODO: DB cache support

    @@queue = nil

    if @@queue.nil?
      credentials_filename = File.expand_path './config/credentials.yml', Rails.root
      credentials = YAML.load_file credentials_filename
      @@queue = {}
      
      credentials.keys.each do |site|
        @@queue[site] = {}

        credentials[site].keys.each do |kind|
          items = credentials[site][kind]

          #FIXME: In the future
          items = [items.first]

          items.each do |item|
            puts "#{credentials[site][kind].index(item) + 1}. Get headers #{item}..."

            _headers = ::ServiceHeaders.for site, kind, item
            item.merge! _headers
          end.compact
          
          @@queue[site][kind] = items
        end
      end
    end
  end
  
  # All credential items.
  #
  # @return [Hash]
  #   valid credential items as a hash with headers.
  #
  def self.queue
    @@queue
  rescue Exception => e
    AccountQueue.initialize_queue!
    @@queue
  end
  
  # Pop an available credential item.
  #
  # @param [Symbol] service
  #   name of service. This can be `:vkontakte` or `:facebook`.
  # @param [Symbol] kind
  #   kind of item. This can be `:accounts` or `:apps`.
  #
  # @return [Hash]
  #   credential item.
  #
  def self.next service, kind
    AccountQueue.initialize_queue! unless self.queue

    if self.queue[service.to_sym][kind.to_sym]
      #TODO: improve this code
      _next = self.queue[service.to_sym][kind.to_sym].shuffle.first
    else
      raise ArgumentError, "Unknown arguments: #{service} and #{kind}"
    end
  end
end
