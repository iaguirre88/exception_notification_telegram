require "exception_notification_telegram/version"
require "HTTParty"

module ExceptionNotifier
  class Error < StandardError; end

  class TelegramNotifier
    def initialize(options)
      @token = options.delete(:token)
      @channel = options.delete(:channel)
    end

    def call(exception, options={})
      message = if options[:accumulated_errors_count].to_i > 1
                  "The exception occurred #{options[:accumulated_errors_count]} times: '#{exception.message}'"
                else
                  "A new exception occurred: '#{exception.message}'"
                end
      message += " on '#{exception.backtrace.first}'" if exception.backtrace

      HTTParty.get("https://api.telegram.org/bot#{@token}/sendMessage?chat_id=#{@channel}&text=#{message}")
    end
  end
end
