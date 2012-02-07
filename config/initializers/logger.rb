Rails.logger = Logger.new(STDOUT)
Rails.logger.level = Logger::DEBUG
Rails.logger.formatter = Logger::Formatter.new