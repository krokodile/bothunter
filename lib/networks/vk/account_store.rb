module AccountStore
  def self.initialize_store!
    credentials_filename = File.expand_path './config/credentials.yml', Rails.root
    credentials = YAML.load_file credentials_filename
    @@queue = {}

    credentials.keys.each do |site|
      @@queue[site] = {}
      credentials[site].keys.each do |kind|
        items = credentials[site][kind]
        @@queue[site][kind] = items
      end
    end
  end

 def self.queue
    @@queue
  rescue Exception => e
    AccountStore.initialize_store!
    @@queue
  end

 def self.next service, kind
    #AccountStore.initialize_store! unless self.queue
    if self.queue[service.to_sym][kind.to_sym]
      _next = self.queue[service.to_sym][kind.to_sym].shuffle.first
      if !(_next['Cookies'].present? & _next["token"].present?)
        _next = self.login( service,kind,_next)
      end
    _next
    else
      raise ArgumentError, "Unknown arguments: #{service} and #{kind}"
    end
  end

  def self.login service, kind, item
    index = self.queue[service.to_sym][kind.to_sym].index(item)
    _headers = ::ServiceHeaders.for service, kind, item
    puts _headers
    item.merge! _headers
    self.queue[service.to_sym][kind.to_sym][index] = item
    item
  end
end