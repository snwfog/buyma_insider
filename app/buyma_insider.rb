require 'dotenv/load'

require 'bundler/setup'
Bundler.require(:default) # , ENV['RACK_ENV']) # disable for now, as it increases boot time

module BuymaInsider
  NAME             = 'buyma_insider'
  SPOOF_USER_AGENT = 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.54 Safari/537.36'
  
  def self.configuration
    @configuration ||= begin
      environment = ENV['RACK_ENV']
      Hashie::Mash.new.tap do |cfg|
        cfg.redis    = Hashie::Mash.new(YAML.load_file('./config/redis.yml')[environment])
        cfg.database = Hashie::Mash.new(YAML.load_file('./config/database.yml')[environment])
        cfg.log      = Hashie::Mash.new(YAML.load_file('./config/log.yml')[environment])
      end
    end
  end
end

require_rel '../lib'
require_rel '../config/initializers/'

require_rel './helpers'
require_rel './models'
require_rel './controllers'
require_rel './serializers'
require_rel './controllers'
require_rel './workers'

