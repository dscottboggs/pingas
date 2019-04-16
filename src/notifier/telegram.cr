require "telegram_bot"
class Pingas::Notifier::Telegram < TelegramBot::Bot
  @chat_id : String
  @api_key : String
  @minimum_severity : Severity
  URL = "http://pingas.tams.tech"
  def initialize(from_json parser : JSON::PullParser)
    _minimum_severity, _chat_id, _api_key = nil, nil, nil
    parser.read_object do |key|
      case key
      when "chat id" then _chat_id = parser.read_string
      when "api key" then _api_key = parser.read_string
      when "minimum severity"
        _minimum_severity = Severity.parse?(parser.read_string)
      end
    end
    if (chat_id = _chat_id) && (api_key = _api_key)
      @chat_id = chat_id
      @api_key = api_key
    else
      parser.raise %<kind "telegram" requires options "api key" and "chat id">
    end
    @minimum_severity = _minimum_severity || Severity::Info
    super "Pingas", @api_key
  end
  def handle(message : TelegramBot::Message))
    Pingas.handle message: message.text
  end
  def notify(message, severity = Severity::Warning)
    if severity >= minimum_severity
      send_message chat_id: @chat_id, text: message
    end
  end
  def spawn_service(error_channel : Channel(Exception))
    fork do
      set_webhook URL
      serve "0.0.0.0", Pingas.config.port # blocks permanently
    rescue e
      error_channel.send e
    end
  end
end
