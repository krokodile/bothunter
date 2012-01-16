class Mechanize::HTTP::Agent
public
  def set_socks addr, port
    set_http unless @http
    class << @http
      def http_class
        Net::HTTP.SOCKSProxy(addr, port)
      end
    end
  end
end
