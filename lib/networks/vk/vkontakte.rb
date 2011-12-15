# encoding: utf-8

class Vkontakte
  class << self
    def find_group group
      group = ::Vk.arg2gid group
      if ::Vk.gid? group
        Group.find_or_create_by(gid: group)
      else
        Group.find_or_create_by(domain: group).first
      end
    end

    def find_person person
      person = ::Vk.arg2uid person

      if ::Vk.uid? person
        Person.find_or_create_by(uid: person)
      else
        Person.find_or_create_by(domain: person)
      end
    end

    def http_post url, options = {}
      uri = URI.parse 'http://vkontakte.ru'

      if options[:cookies]
        cookies = options[:cookies]
      else
        cookies = AccountQueue.next(:vkontakte, :accounts)['Cookies']
      end

      RestClient.post(
        uri.merge(url).to_s,
        options,
        {
          cookies: cookies
        }
      ).encode('utf-8', 'windows-1251')
    end
    
    def http_get url, options = {}
      uri = URI.parse 'http://vkontakte.ru'

      if options[:cookies]
        cookies = options[:cookies]
      else
        cookies = AccountQueue.next(:vkontakte, :accounts)['Cookies']
      end

      RestClient.get(
        uri.merge(url).to_s,
        {
          cookies: cookies
        }.merge(options)
      ).encode('utf-8', 'windows-1251')
    end
    
    def parse_each_item options = {}, &block
      raise ArgumentError, 'offset must be integer' unless options[:offset].is_a? Integer
      raise ArgumentError, 'method must be GET or POST' unless ['post', 'get'].include? options[:method]

      _proc = options[:method] == 'get' ? method(:http_get) : method(:http_post)

      _count = 0
      _begin = Time.now

      items, threads = [], []
      offset = -options[:offset].to_i
      thread_count = options[:thread_count].to_i > 0 ? options[:thread_count].to_i : 1
      puts "select threads"
      thread_count.times do |id|
        threads << Thread.new(id) do |thread_id|
          _thread_offset = (offset += options[:offset].to_i)
          _cookie = options[:cookies]
          while !(_cookie.present?)
            begin
              _cookie = AccountQueue.next(:vkontakte, :accounts)['Cookies']
            rescue Exception => e
              puts "Can not login"
            end
          end
          #_cookie = AccountQueue.next(:vkontakte, :accounts)['Cookies']
          _sleep_thread = 1

          loop do
            begin
              _start = Time.now
          
              data = _proc.call(
                options[:url],
                options[:params].merge({
                  offset: _thread_offset,
                  cookies: _cookie
                })
              )

              _items = (data.to_nokogiri_html(true) / options[:item_for_parse]).map { |item|
                item.inner_html.force_encoding('utf-8')
              }

              if _items.empty? or _items.nil?
                if data.to_s =~ /Вы попытались загрузить более одной однотипной страницы в секунду/u
                  puts "VK says no more!"
                  sleep(_sleep_thread += (1.0 / (rand(10) + 0.1)))
                else
                  puts "no items found"
                  break
                end
              else
                if options[:last_date].is_a?(DateTime) and (last_item_date = russian_date_scan(_items.first))
                  stop_date = options[:last_date]
                  if last_item_date <= stop_date
                    _items.select! do |_item|
                      item_date = russian_date_scan(_item)
                      item_date <= stop_date rescue false
                    end

                    break
                  end
                end

                _thread_offset = (offset += options[:offset].to_i)
              end
            rescue Exception => e
              puts "ERROR!!!!!11"
              Rails.logger.warn e, e.message
            ensure
              items += _items.to_a unless _items.nil? or _items.empty?
          
              if thread_id == 1 and items.count > 10_000
                yield items.compact.uniq
            
                items.clear
              end

              GC.start
            end
          end
        end
      end

      threads.each &:join

      yield items.compact.uniq
    end
  end
end
