module AccountStore

  def self.initialize_store!
   # puts self.credentials
   # puts self.credentials[:apps]
    @@queue = {}

    self.credentials.keys.each do |site|
      @@queue[site] = {}
      self.credentials[site].keys.each do |kind|
        if kind==:accounts
          items = self.credentials[site][kind]
          @@queue[site][kind] = items
          @@queue[site][kind].each {|item| self.login site, kind, item}
        end
      end
    end
  end

 def self.credentials
  begin
   @@credentials
  rescue Exception => e
   credentials_filename = File.expand_path './config/credentials.yml', Rails.root
   credentials = @@credentials =  YAML.load_file credentials_filename
   @@credentials
   end
 end

 def self.queue
    @@queue
  rescue Exception => e
    #AccountStore.initialize_store!
    @@queue
  end

 def self.next_socks
   host = self.credentials[:vkontakte][:tor_socks][:host]
   port = self.credentials[:vkontakte][:tor_socks][:ports_range].to_a.shuffle.first
   {:host => host, :port => port}
 end

 def self.mechanize
   client = Mechanize.new
   socks = self.next_socks
   client.agent.set_socks(socks[:host], socks[:port])
 end

  def self.next_app
    app = self.credentials[:vkontakte][:apps].shuffle.first
    {:id => app[:id], :secret =>app[:secret]}
  end

 def self.next service, kind
    #AccountStore.initialize_store! unless self.queue
    if self.queue[service.to_sym][kind.to_sym]
      _next = self.queue[service.to_sym][kind.to_sym].shuffle.first
      if !(_next["token"].present?)
        begin
          _next = self.login( service,kind,_next)
        rescue
          Rails.logger.error("incorrect login for #{_next}")
          self.next(service,kind)
        end
      end
    _next
    else
      raise ArgumentError, "Unknown arguments: #{service} and #{kind}"
    end
 end

  def self.drop_token! service, kind,token
    item = self.queue[service.to_sym][kind.to_sym].index{|item| item['token']==token}
    item["token"] = nil
  end

  def self.login service, kind, item
    puts "try to log in by #{item['username']}"
    index = self.queue[service.to_sym][kind.to_sym].index(item)
    _headers = ::ServiceHeaders.for service, kind, item
    #puts _headers
    item.merge! _headers
    self.queue[service.to_sym][kind.to_sym][index] = item
    puts "succesfully logged in by #{item['username']}"
    item
  end
end