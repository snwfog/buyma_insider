module Worker
  class Base
    include ::Sidekiq::Worker

    attr_accessor :standard_headers

    def initialize
    end

    # def perform(args)
    #   perform_safe(args)
    # rescue => ex
    #   Raven.capture_exception(ex)
    #   logger.error(ex)
    # end
    #
    # def perform_safe(args)
    #   raise 'Not implemented'
    # end

    protected

    def slack_notify(params = {})
      BuymaInsider
        .configuration
        .slack_notifier
        .post(params.merge!(channel: '#jobs'))
    end

    def validate_args(args, validator, message)
      unless validator.call(args)
        logger.error "#{self} aborted, arguments #{message}" and raise
      end
    end

    # Fetch uri with capture to Sentry.io
    # return RestClient::RawResponse
    def fetch_uri(uri, verify_ssl = false, retries = 3, request_headers, **args)
      retry_count = 0

      logger.info "`GET` #{uri}"
      logger.debug JSON.pretty_generate(request_headers)
      RestClient::Request.execute(url:          uri,
                                  method:       :get,
                                  verify_ssl:   verify_ssl,
                                  raw_response: true,
                                  headers:      request_headers,
                                  **args)

    rescue OpenSSL::SSL::SSLError
      retry_count += 1
      logger.warn 'Fetching `%s` failed with SSL error (%i times)' % [uri, retry_count]
      retry if retry_count <= retries
      nil
    rescue => ex
      Raven.capture_exception(ex)
      logger.error 'Fail fetch uri `%s`' % uri
      logger.error ex.message
      raise
    end
  end
end
