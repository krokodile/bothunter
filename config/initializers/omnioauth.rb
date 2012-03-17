config_file = File.expand_path "./config/oauth_credentials.yml", Rails.root
oauth_config = YAML::load_file(config_file)[Rails.env]

Rails.application.config.middleware.use OmniAuth::Builder do
  oauth_config.each do |provider, params|
    provider provider.to_sym, params['id'], params['secret'], params['params']
  end
end
