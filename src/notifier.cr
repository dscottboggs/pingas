require "./severity"
require "./notifier/*"

abstract class Pingas::Notifier
  def self.new(pull parser : JSON::PullParser)
    kind = nil
    parser.read_object do |key|
      case key
      when "kind" then kind = parser.read_string
      when "options"
        case k = kind
        when nil
          parser.raise %<"kind" must be specified first when defining a notifier>
        when "telegram"
          return Notifier::Telegram.new pull: parser
        end
      end
    end
  end

  abstract def notify(msg, severity = Severity::Warning)
end
