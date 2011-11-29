module Fb
  class API
    attr_reader :token

    def initialize token
      @token = token
    end

    def explorer path, params = {}
      Fb::API.explorer path, @token, params
    end

    def self.explorer path, token = nil, params = {}
      params.merge!({
        format: 'json',
        method: 'GET',
      })
      params.merge! access_token: token if token
      params = params.map {|k,v| "#{k}=#{URI.escape v.to_s}"}.join('&')

      JSON.parse open("https://graph.facebook.com/#{path}?#{params}").read rescue nil
    end
  end

  class API::Data
    include Enumerable
    
    def initialize token, path
      @api = Fb::API.new token
      @path = path
    end

    def each
      if block_given?
        data = @api.explorer @path

        if data.present? and data.respond_to?(:has_key?) and data.has_key? 'paging'
          loop do
            data['data'].each do |item|
              yield Fb::API::Item.new(item)
            end if data['data']

            next_page = data['paging'].try(:[], 'next')
            raise StopIteration unless next_page
            data = JSON.parse open(next_page).read
          end
        elsif data.present? and data.respond_to?(:has_key?) and 
              data.has_key? 'data' and data['data'].respond_to?(:each)

          data['data'].each do |item|
            yield Fb::API::Item.new(item)
          end
        end
      end
    end
  end

  class API::Item
    attr_reader :type, :text, :src, :author_id, :item_id, :hash, :created_at, :comments_count, :likes_count

    def initialize item
      @hash = item
      @item_id = item['id']
      @type = item['type'] #TODO: Recognize a type
      @text = item['name'].presence || item['message'].presence || item['story'].presence || item['description']
      @src = item['picture']
      @author_id = item['from'].try(:[], 'id')
      @comments_count = item['comments'].try(:[], 'count') || 0
      @likes_count = item['likes'].try(:[], 'count') || 0
      @created_at = ::DateTime.parse(item['created_time']) rescue nil
    end

    def to_hash
      @hash
    end
  end

  class API
    def self.Feed token, path
      Fb::API::Data.new(token, "#{path}/feed").to_enum
    end

    def self.Posts token, path
      Fb::API::Data.new(token, "#{path}/posts").to_enum
    end

    def self.Photos token, path
      Fb::API::Data.new(token, "#{path}/photos").to_enum
    end

    def self.Videos token, path
      Fb::API::Data.new(token, "#{path}/videos").to_enum
    end

    def self.Likes token, path
      Fb::API::Data.new(token, "#{path}/likes").to_enum
    end
  end
end
