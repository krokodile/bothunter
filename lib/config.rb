module YAMLConfig
  def self.load_config
    @@config ||= {}

    unless @@config.empty?
      @@config
    else
      config_file = File.expand_path "./config/credentials.yml", Rails.root
      @@config = YAML.load_file config_file
    end
  end

  def self.method_missing name, *args, &block
    load_config[name.to_s]
  end

  def self.[] name
    load_config[name.to_s]
  end
end
