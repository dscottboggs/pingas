require "telegram_bot"

# The telegram notifier may be used to specify a telegram bot which will send
# notifications and receive commands in reply, based on the configurations under
# the "options" key. For example:
# ```json
# {
#   ...
#   "notifiers": {
#     "a telegram bot": {
#       "chat id": "some chat ID",
#       "api key": "an authorized API key",
#       "minimum severity": "Warning",
#       "service port": 11011
#     }
#   }
# }
# ```
#
# The obove configuration will not send notifications below a "Warning" severity,
# and listens for replies on port 11,011 (the default).
class Pingas::Notifier::Telegram < TelegramBot::Bot
  include Pingas::Notifier
  property chat_id : String
  property api_key : String
  property minimum_severity : Severity
  property port : UInt16 { 11_011_u16 }
  URL = "http://pingas.tams.tech"

  def initialize(from_json parser : JSON::PullParser)
    @minimum_severity = Severity::Info
    chat_id_set, api_key_set = false, false
    @chat_id = uninitialized String
    @api_key = uninitialized String
    parser.read_object do |key|
      case key
      when "chat id"
        @chat_id = parser.read_string
        chat_id_set = true
      when "api key"
        @api_key = parser.read_string
        api_key_set = true
      when "service port" then @port = parser.read_int.to_u16!
      when "minimum severity"
        if sev = Severity.parse?(parser.read_string)
          @minimum_severity = sev
        end
      end
    end
    unless chat_id_set && api_key_set
      raise JSON::ParseException.new <<-HERE, parser.line_number, parser.column_number
      "chat id" and "api key" keys must be specified for the telegram "kind"
      notifier
      HERE
    end
    super "Pingas", @api_key
  end
  def to_json(builder : JSON::Builder)
    builder.object do
      builder.field "kind", "telegram"
      builder.field "options" do
        builder.object do
          builder.field "chat_id", chat_id
          builder.field "api_key", api_key
          builder.field "minimum_severity", minimum_severity.to_s
          builder.field "port", port unless port == 11_011_u16
        end
      end
    end
  end

  def handle(message : TelegramBot::Message)
    if text = message.text
      Pingas.handle message: text
    end
  end

  def notify(message : String, severity = Severity::Warning)
    if severity >= minimum_severity
      send_message chat_id: @chat_id, text: message
    end
  end

  def spawn_service(error_channel : Channel(Exception))
    fork do
      set_webhook URL
      # blocks permanently
      serve "0.0.0.0", port.to_i
    rescue e
      error_channel.send e
      spawn_service error_channel
    end
  end
end
