require 'exception_notification_telegram/version'
require 'httparty'
require 'json'

module ExceptionNotifier
  class TelegramNotifier
    def initialize(options)
      @token = options.delete(:token)
      @channel = options.delete(:channel)
    rescue StandarError
      @token = @channel = nil
    end

    def call(exception, options = {})
      @options = options
      @exception = exception

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
        header,
        '',
        "⚠️ Error 500 in #{defined?(Rails) ? Rails.env : 'N/A'} ⚠️",
        "*#{exception.message.tr('`', "'")}*"
      ]

      text += message_request
      text += message_backtrace

      text.join("\n")
    end

    def header
      text = ["\nApplication: *#{app_name}*"]

      errors_text = errors_count > 1 ? errors_count : 'An'
      text << "#{errors_text} *#{exception.class}* occured#{controller_text}."

      text
    end

    def message_request
      return [] unless (env = options[:env])

      request = ActionDispatch::Request.new(env)

      [
        '',
        '*Request:*',
        '```',
        "* url : #{request.original_url}",
        "* http_method : #{request.method}",
        "* ip_address : #{request.remote_ip}",
        "* parameters : #{request.filtered_parameters}",
        "* timestamp : #{Time.current}",
        '```'
      ]
    end

    def message_backtrace
      backtrace = exception.backtrace

      return [] unless backtrace

      text = []

      text << ''
      text << '*Backtrace:*'
      text << '```'
      backtrace.first(3).each { |line| text << "* #{line}" }
      text << '```'

      text
    end

    def app_name
      @app_name ||= options[:app_name] || rails_app_name || 'N/A'
    end

    def errors_count
      @errors_count ||= options[:accumulated_errors_count].to_i
    end

    def rails_app_name
      Rails.application.class.name.underscore if defined?(Rails)
    end

    def controller_text
      env = options[:env]
      controller = env ? env['action_controller.instance'] : nil

      " in *#{controller.controller_name}##{controller.action_name}*" if controller
    end
  end
end
