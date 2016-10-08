require 'require_all'
require 'dotenv'

require_rel '../config/initializers'
require_rel 'buyma_insider'

Dotenv.load

module BuymaInsider
  NAME             = 'buyma_insider'
  ENVIRONMENT      = ENV['ENVIRONMENT']
  SPOOF_USER_AGENT = 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.57 Safari/537.36'
end
