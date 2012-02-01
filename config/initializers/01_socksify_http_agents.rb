# Mechanize: call @agent.set_socks(addr, port) before using
require "socksify"
require 'socksify/http'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class Mechanize::HTTP::Agent
public
  def set_socks addr, port
    set_http unless @http
    class << @http
      attr_accessor :socks_addr, :socks_port

      def http_class
        Net::HTTP.SOCKSProxy(socks_addr, socks_port)
      end
    end
    @http.socks_addr = addr
    @http.socks_port = port
  end
end

# use w/ OAuth2 like OAuth2::Client.new(id, secret, connection_opts: { proxy: 'socks://127.0.0.1:9050' })
class Faraday::Adapter::NetHttp
  def net_http_class(env)
    if proxy = env[:request][:proxy]
      if proxy[:uri].scheme == 'socks'
        Net::HTTP::SOCKSProxy(proxy[:uri].host, proxy[:uri].port)
      else
        Net::HTTP::Proxy(proxy[:uri].host, proxy[:uri].port, proxy[:user], proxy[:password])
      end
    else
      Net::HTTP
    end
  end
end
