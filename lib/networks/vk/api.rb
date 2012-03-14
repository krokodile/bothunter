# encoding: utf-8

module Vk

require 'oauth2'
require 'mechanize'

# = Synopsis
# The library is used
#
# == Example
#   require 'vkontakte'
#   vk = Client.new(CLIENT_ID, CLIENT_SECRET)
#   vk.login!(email, pass)
#   friends = vk.api.friends_get(:fields => 'online')
class Client
  attr_reader :api, :access_token

  ##
  # The version of <> you are using
  VERSION = '3.0'

  class Error < RuntimeError
  end

  def initialize
    #credentials = AccountQueue.next :vkontakte, :apps
    app = AccountStore.next_app
    @socks = AccountStore.next_socks
    client_id     =  app[:id]
    client_secret = app[:secret]
    @authorize     = false
    @api           = nil

    # http://vkontakte.ru/developers.php?o=-1&p=%C0%E2%F2%EE%F0%E8%E7%E0%F6%E8%FF
    @client = OAuth2::Client.new(
      client_id,
      client_secret,
      :site          => 'https://api.vk.com/',
      :token_url     => '/oauth/token',
      :authorize_url => '/oauth/authorize',
      #connection_opts: { proxy: "socks://#{@socks[:host]}:#{@socks[:port]}" }
    )

  end

  # http://vkontakte.ru/developers.php?o=-1&p=%CF%F0%E0%E2%E0%20%E4%EE%F1%F2%F3%EF%E0%20%EF%F0%E8%EB%EE%E6%E5%ED%E8%E9
  #
  def login!(email, pass, scope = 'friends')
    # Create a new mechanize object
    agent = Mechanize.new{|agent| agent.user_agent = 'Opera/9.80 (J2ME/MIDP; Opera Mini/9.80 (S60; SymbOS; Opera Mobi/23.348; U; en) Presto/2.5.25 Version/10.54'}
    #agent.read_timeout=15
    #agent.agent.set_socks(@socks[:host],@socks[:port])
    auth_url = @client.auth_code.authorize_url(
      :redirect_uri => 'https://api.vk.com/blank.html',
      :scope        => scope,
      :display      => 'wap'
    )
    #puts auth_url

    # Get the Vkontakte sing in page
    login_page = agent.get(auth_url)

    # Fill out the login form
    login_form       = login_page.forms.first
    login_form.email = email
    login_form.pass  = pass

    verify_page = login_form.submit

    if verify_page.uri.path == '/oauth/authorize'
      if /m=4/.match(verify_page.uri.query)
        raise Error, "Incorrect login or password"
      elsif /s=1/.match(verify_page.uri.query)
        grant_access_page = verify_page.forms.first.submit
      end
    else
      grant_access_page = verify_page
    end

    code = /code=(?<code>.*)/.match(grant_access_page.uri.fragment)['code']

    @access_token = @client.auth_code.get_token(code)
    @access_token.options[:param_name] = 'access_token'
    @access_token.options[:mode] = :query

    @api = API.new(@access_token)
    @authorize = true
  end

  def authorized?
    @authorize ? true : false
  end

end

class API
  def initialize(access_token=nil)
    if access_token.present?
      @access_token = access_token
    else
      reset_token!
    end


  end

  def reset_token!
    @access_token = ::AccountStore.next(:vkontakte, :accounts)['token']
  end

  def method_missing(method, *args)
    vk_method = method.to_s.split('_').join('.')
    response = execute(vk_method, *args).parsed
    if response['error']
      error_code = response['error']['error_code']
      error_msg  = response['error']['error_msg']
      if [1,6].include? error_code
        sleep 2
        method_missing(method, *args)
      elsif [4,5].include? error_code
        AccountStore.drop_token!(:vkontakte, :accounts, @access_token)
        reset_token!
      else
        raise VkException.new(vk_method, error_code, error_msg), "Error in `#{vk_method}': #{error_code}: #{error_msg}"
      end
    end

    return response['response']
  end

  private

  # http://vkontakte.ru/developers.php?o=-1&p=%C2%FB%EF%EE%EB%ED%E5%ED%E8%E5%20%E7%E0%EF%F0%EE%F1%EE%E2%20%EA%20API
  def execute(method, params = {})
    method = "/method/#{method}"

    @access_token.get(method, :params => params, :parce => :json)
  end

end

class VkException < Exception
  attr_reader :vk_method, :error_code, :error_msg

  def initialize(vk_method, error_code, error_msg)
    @vk_method  = vk_method
    @error_code = error_code.to_i
    @error_msg  = error_msg
  end
end
end