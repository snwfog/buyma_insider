class ApplicationController < Sinatra::Base
  include Elasticsearch::DSL

  register Sinatra::CrossOrigin

  helpers Sinatra::Param
  helpers Sinatra::Cookies

  helpers RouteHelper
  helpers JsonHelper
  helpers CacheHelper
  helpers ElasticsearchHelper
  helpers AuthenticationHelper

  disable :run
  disable :static
  disable :views
  disable :show_exceptions

  # Sinatra
  set :root, File.expand_path('../../..', __FILE__)

  # Contrib
  enable :cross_origin
  set :allow_methods, [:post, :get, :patch, :put, :options, :delete]

  # Custom
  enable :logging # CommonLogger from sinatra
  # Doesn't work, because this set to self.class.logger
  # set    :logger, BuymaInsider.logger_for(:Sinatra) # Allow controller logging

  # Settings
  # explicitly set this
  set :environment, BuymaInsider.environment

  # set :env, ENV['RACK_ENV'] # this is default

  # Custom settings
  # This setting will let active model serializer serialize
  # all declared relationship, instead of using the resource identifier
  # default serializer that will return only id and type
  enable :deep_serialization

  # Global constants
  set :SESSION_TOKEN, :_t

  configure do
    set :cache, {}
  end

  configure :development do
    enable :static # serve static files from public dir
  end

  configure :production do
    # Sinatra log request to file as well as STDOUT
    use Rack::CommonLogger, Logging.logger[:Sinatra]
  end

  before do
    content_type :json
    cache_control :private, :no_cache, :no_store, :must_revalidate
  end

  error [UserNotFound, InvalidPassword, InvalidSession] do
    # { error: 'login.invalid_username_or_password' }
    # TODO: Unauthorized...
    status :bad_request
  end

  def logger
    BuymaInsider.logger_for(:Sinatra)
  end
end