require 'exception_notification'
require 'exception_notification_telegram/version'
require 'httparty'
require 'json'

module ExceptionNotifier
  class TelegramNotifier
    def initialize(options)
      @token = options.delete(:token)
      @channel = options.delete(:channel)

      raise ArgumentError, "You must provide 'token' and 'channel' option" unless @token && @channel
    end

    def call(exception, options = {})
      @options = options
      @exception = exception

      @formatter = Formatter.new(exception, options)

      url = "https://api.telegram.org/bot#{@token}/sendMessage"
      HTTParty.post(url, httparty_options)
    end

    private

    attr_reader :options, :exception

    def httparty_options
      payload = {
        chat_id: @channel,
        text: message,
        parse_mode: 'Markdown'
      }

      httparty_options = {}
      httparty_options[:headers] = { 'Content-Type' => 'application/json' }
      httparty_options[:body] = payload.to_json
      httparty_options
    end

    def message
      text = [
        "\nApplication: *#{@formatter.app_name || 'N/A'}*",
        @formatter.subtitle,
        '',
        @formatter.title,
        "*#{exception.message.tr('`', "'")}*"
      ]

      if (request = @formatter.request_message.presence)
        text << ''
        text << '*Request:*'
        text << request
      end

      if (backtrace = @formatter.backtrace_message.presence)
        text << ''
        text << '*Backtrace:*'
        text << backtrace
      end

      text.join("\n")
    end
  end
end
