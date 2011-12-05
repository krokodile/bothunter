require 'redis'
require 'digest/md5'

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
  def self.redis_store
    @@_redis ||= Redis.new
  end

  def self.key
    time = Time.now.strftime('%Y-%m')
    credentials_content = open(File.expand_path './config/credentials.yml', Rails.root).read
    credentials_md5 = Digest::MD5.hexdigest credentials_content
    "BotHunter::AccountQueue::#{credentials_md5}::#{time}"
  end

  def self.clear!
    redis_store.set key, nil
  end

  # Initialize accounts queue.
  #
  def self.initialize_queue!
    @@queue = redis_store.get key

    if @@queue.nil? or @@queue.empty?
      credentials_filename = File.expand_path './config/credentials.yml', Rails.root
      credentials = YAML.load_file credentials_filename
      @@queue = {}
      
      credentials.keys.each do |site|
        @@queue[site] = {}

        credentials[site].keys.each do |kind|
          items = credentials[site][kind]
          items.each do |item|
            puts "#{credentials[site][kind].index(item) + 1}. Get headers #{item}..."

            _headers = ::ServiceHeaders.for site, kind, item
            item.merge! _headers
          end.compact
          
          @@queue[site][kind] = items
        end
      end
      
      redis_store.set key, @@queue.to_yaml
    else
      @@queue = YAML.load @@queue
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
      if self.queue[service.to_sym][kind.to_sym].is_a? Array
        self.queue[service.to_sym][kind.to_sym] = self.queue[service.to_sym][kind.to_sym].cycle
      end

      _next = self.queue[service.to_sym][kind.to_sym].next
    else
      raise ArgumentError, "Unknown arguments: #{service} and #{kind}"
    end
  end
end