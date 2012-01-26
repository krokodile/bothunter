# Class that implements service {http://vk.com Vkontakte}.
# @see ServiceHeaders
#
class VkontakteHeaders < ServiceHeaders
  class << self
    def apps item
      {}
    end

    def accounts item
      puts "try to get accounts"
      #cookies = self.user_sign_in item[:username], item[:password]
      token = self.get_user_token item[:username], item[:password]
      #puts "token is: #{token}"
      {'token' => token }
    end
    
    def user_sign_in username, password
      puts "logging in"
      uri = URI.parse 'http://vkontakte.ru'
      
      bot = Mechanize.new do |agent|
        agent.default_encoding = 'utf-8'
        agent.force_default_encoding = 'utf-8'
      end
      
      bot.get uri do |page|
        after_login = page.form_with name: 'login' do |f|
          f.email = username
          f.pass  = password
        end.click_button
      end
      
      cookies = Hash[bot.cookies.map {|v| v.to_s.split ?=}]
      
      unless cookies['remixsid'].nil?
        cookies
      else
        raise ArgumentError, "Account '#{username}:#{password}' is invalid."
      end
    end

    def get_user_token username,password
      client = ::Vk::Client.new
      client.login! username,password
      puts "token is #{client.access_token}"
      client.access_token
    end
  end
end
