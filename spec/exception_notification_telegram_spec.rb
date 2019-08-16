require 'exception_notification_telegram'

RSpec.describe ExceptionNotificationTelegram do
  it 'has a version number' do
    expect(ExceptionNotificationTelegram::VERSION).not_to be nil
  end

  context 'with valid options' do
    before do
      @exception = fake_exception
      allow(@exception).to receive(:backtrace) { fake_backtrace }
      allow(@exception).to receive(:message) { 'some message' }

      allow(HTTParty).to receive(:post)
    end

    it 'sends a telegram message' do
      options = {
        channel: '@channel_name',
        token: 'SOME-TOKEN'
      }

      telegram_notifier = ExceptionNotifier::TelegramNotifier.new(options)
      telegram_notifier.call(@exception)

      expected_url = 'https://api.telegram.org/botSOME-TOKEN/sendMessage'
      expected_body = {
        body: {
          chat_id: '@channel_name',
          text: expected_message,
          parse_mode: 'Markdown'
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      }

      expect(HTTParty).to have_received(:post).with(expected_url, expected_body)
    end
  end

  context 'with invalid options' do
    it 'raises an error' do
      expect { ExceptionNotifier::TelegramNotifier.new }
        .to raise_error(ArgumentError)
    end
  end

  private

  def fake_exception
    5 / 0
  rescue StandardError => e
    e
  end

  def fake_backtrace
    [
      'backtrace line 1',
      'backtrace line 2'
    ]
  end

  def expected_message
    '
Application: *N/A*
A *ZeroDivisionError* occurred.

⚠️ Error occurred ⚠️
*some message*

*Backtrace:*
```
* backtrace line 1
* backtrace line 2
```'
  end
end
