class Vk::VKClient
  credentials_filename = File.expand_path './config/credentials.yml', Rails.root
  credentials = YAML.load_file credentials_filename
  super_users = {}
  api_instances = {}

  def self.client
    Mechanize.new
  end

  def self.proxied_client
    client = self.client

  end

  def self.api

  end


  def self.with_user

  end

  def self.with_superuser

  end
end