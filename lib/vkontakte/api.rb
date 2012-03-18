module Vk
  class API
    class << self
      def call_method token, method, params = {}
        escaped_params = (params.map{ |k, v| "#{k}=#{v}" }).join('&')

        url_string = "https://api.vk.com/method/#{method}?"
        url_string += "#{escaped_params}&" if escaped_params.present?
        url_string += "access_token=#{token}"

        url = URI.escape url_string
        parser = Yajl::Parser.new
        body = parser.parse Faraday.get(url).body

        result = body["response"]

        if result.is_a?(Array) && result.size == 1
          result.shift
        else
          result
        end
      end

      def get_current_session_token
        @@token ||= get_new_token
      end

      def get_new_token scopes = ['offline', 'groups']
        agent = Mechanize.new
        agent.user_agent_alias = 'Mac Safari'

        login_page = agent.get 'http://vk.com'
        login_page.forms.first.email = 'login'
        login_page.forms.first.pass = 'password'

        agent.submit login_page.forms.first

        if agent.cookies.detect{ |cookie| cookie.name == 'remixsid' }
          params = {
              client_id: '2812333',
              scope: scopes .join(','),
              display: :page,
              redirect_uri: 'http://api.vkontakte.ru/blank.html',
              response_type: :token
          }

          params_string = (params.map{ |k, v| "#{k}=#{v}" }).join('&')
          url_with_params = "http://api.vk.com/oauth/authorize?#{params_string}"
          page = agent.get url_with_params
          reg = /\Ahttp:\/\/api\.(vkontakte\.ru|vk\.com)\/.+\#access_token=(?<token>.*?)&expires_in=/
          page.uri.to_s.match(reg)['token'] rescue nil
        end
      end
    end

    @@token = self.get_new_token
  end
end
