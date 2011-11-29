# encoding: utf-8

module Vk
  class API
    attr_reader :app_id, :app_secret

    def initialize
      credentials = AccountQueue.next :vkontakte, :apps

      @app_id = credentials[:id]
      @app_secret = credentials[:secret]
    end

    def sig params
      params = {
        api_id: @app_id,
        format: 'json',
        rnd: rand(1000),
        timestamp: Time.now.to_i,
        v: '3.0',
      }.merge params

      _sig = Digest::MD5.hexdigest params.keys.sort.map { |key|
        "#{key}=#{params[key]}"
      }.join + @app_secret

      params[:sig] = _sig

      params
    end

    def method_missing method, *args, &block
      call method, args.first.is_a?(Hash) ? args.first : {}, &block
    end

    def call method, options = {}, &block
      params = { method: camelize(method.to_s).gsub(/^(.?)/) { $1.downcase } }
      params.merge! options

      response = ::JSON::parse(
        RestClient.post(
          'http://api.vk.com/api.php',
          sig(params)
        )
      )

      raise ServerError, response if response['error']

      if block
        yield response['response']
      else
        response['response']
      end
    end

    private

    def camelize lower_case_and_underscored_word, first_letter_in_uppercase = true
      if first_letter_in_uppercase
        lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      else
        lower_case_and_underscored_word.to_s[0].chr.downcase + camelize(lower_case_and_underscored_word)[1..-1]
      end
    end
  end
end
