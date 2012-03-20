require 'digest/md5'
require 'uri'

class RobokassaMerchant
  class << self

    # we aren't use signed params in this app
    #def signed_start_params groups_limit, objects_filter, objects_cost, profile
    #  hash = {
    #    'groups_limit' => groups_limit.to_s,
    #    'objects_filter' => objects_filter.to_s,
    #    'objects_cost'   => objects_cost.to_s,
    #    'user_id'        => profile.id.to_s,
    #    'user_token'     => profile.attributes.to_s
    #  }

    #  hash['user_token'] = Digest::MD5.hexdigest(query('user_token' => Digest::MD5.digest(query(Hash[hash.sort]))))

    #  query(hash)
    #end


    def signed_start_params groups_limit, objects_cost, user # objects_filter,

      hash = {
        'groups_limit' => groups_limit.to_s,
        #'objects_filter' => objects_filter.to_s,
        'objects_cost'   => objects_cost.to_s,
        'user_id'        => user.id.to_s,
        'user_token'     => user.attributes.to_s
      }

      hash['user_token'] = Digest::MD5.hexdigest(query('user_token' => Digest::MD5.digest(query(Hash[hash.sort]))))

      query(hash)
    end

    def parse_query string 
      Hash[string.split('&').map{ |pair| pair = pair.split('=', 2); [pair[0], URI.unescape(pair[1])] }]
    end

    def query hash
      hash.keys.map{ |key| [key, URI.escape(hash[key])].join '=' }.join '&'
    end
  end

  def initialize app, settings
    @app = app
    @settings = settings
  end

  def call env
    @env = env

    if env['PATH_INFO'] =~ /^\/robokassa\//
      params = self.class.parse_query env['QUERY_STRING']

      case env['PATH_INFO']
      when /start$/ then
        #return [404, {}, []] if [params['user_id'], params['objects_cost']].include? nil
        digest = params.delete('user_token')
        user = User.find(params['user_id'])
        params['user_token'] = user.attributes.to_s

        return [403, {}, []] unless digest == Digest::MD5.hexdigest(self.class.query('user_token' => Digest::MD5.digest(self.class.query(Hash[params.sort]))))

        #order_id = params['order_id']
        #order = Order.find order_id rescue return [404, {}, []]
        
        invoice = RobokassaInvoice.create! :user_id => params['user_id'], :money_amount => Fixnum.cents(params['objects_cost']), :groups_limit => params['groups_limit'] #, :objects_filter => params['objects_filter']
        invoice_id = invoice.id.to_s

        query = {}

        query['MrchLogin'] = @settings['MerchantLogin']
        query['OutSum'] = invoice.money_amount.cost
        query['InvId'] = '0'
        query['shpInvoiceId'] = invoice_id
        query['SignatureValue'] = Digest::MD5.hexdigest("#{query['MrchLogin']}:#{query['OutSum']}:#{query['InvId']}:#{@settings['MerchantPass1']}:shpInvoiceId=#{invoice_id}") 

        query['InvDesc'] = "#{user.full_name}"

        query = self.class.query(query)
        
        url = URI.parse(@settings['InitUrl'])
        url.query = (url.query || '') + query

        return [302, { 'Location' => url.to_s }, []]

      when /result$/ then # можно отрефакторить, т. к. код в целом одинаковый
        out_sum = params['OutSum']
        inv_id = params['InvId']
        signature_value = params['SignatureValue']
        invoice_id = params['shpInvoiceId']

        return [400, {}, []] if [out_sum, inv_id, signature_value, invoice_id].include? nil

        digest = Digest::MD5.hexdigest("#{out_sum}:#{inv_id}:#{@settings['MerchantPass2']}:shpInvoiceId=#{invoice_id}")
  
        return [401, {}, []] unless digest.downcase == signature_value.downcase

        invoice = RobokassaInvoice.find invoice_id rescue return [404, {}, []]

        return [409, {}, []] if invoice.paid

        return [403, {}, []] unless invoice.money_amount.cost? out_sum
        invoice.user.inc :groups_limit, invoice.groups_limit

        invoice.set :paid, true
        invoice.set :robokassa_invoice_id, inv_id.to_i

        return [200, { 'Content-Type' => 'text/plain' }, ["OK#{inv_id}"]]
        
      when /success$/ then
        out_sum = params['OutSum']
        inv_id = params['InvId']
        signature_value = params['SignatureValue']
        invoice_id = params['shpInvoiceId']

        return [400, {}, []] if [out_sum, inv_id, signature_value, invoice_id].include? nil

        digest = Digest::MD5.hexdigest("#{out_sum}:#{inv_id}:#{@settings['MerchantPass1']}:shpInvoiceId=#{invoice_id}")
  
        return [401, {}, []] unless digest.downcase == signature_value.downcase

        invoice = RobokassaInvoice.find invoice_id rescue return [404, {}, []]

        # вполне вероятная ситуация при отсутствии связи между робокассой и сервером
        unless invoice.paid
          return [403, {}, []] unless invoice.money_amount.cost? out_sum
          invoice.user.inc :groups_limit, invoice.groups_limit

          invoice.set :paid, true
          invoice.set :robokassa_invoice_id, inv_id.to_i
        end

        flash[:notice] = 'Invoice has been paid successfully!'

        return [301, { 'Location' => "/" }, []]

      when /fail$/ then
        invoice_id = params['shpInvoiceId']
        invoice = RobokassaInvoice.find invoice_id rescue return [404, {}, []]

        flash[:error] = 'Your payment failed.'

        return [301, { 'Location' => "/" }, []]

      else [404, {}, []]
      end
    else
      @app.call env
    end
  end

  def flash
    @env['action_dispatch.request.flash_hash'] = @env['action_dispatch.request.flash_hash'] || ActionDispatch::Flash::FlashHash.new
  end
end
