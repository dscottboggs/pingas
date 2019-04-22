require "./severity"
require "./notifier/*"

module Pingas::Notifier
  def self.new(pull parser : JSON::PullParser)
    kind = nil
    parser.read_object do |key|
      case key
      when "kind" then kind = parser.read_string
      when "options"
        case k = kind
        when nil
          raise JSON::ParseException.new <<-HERE, parser.line_number, parser.column_number
            key "kind" must be specified before "options" in the configuration.
          HERE
        when "telegram"
          n = Notifier::Telegram.new from_json: parser
          parser.read_end_object
          return n
        end
      end
    end
    raise JSON::ParseException.new <<-HERE, parser.line_number, parser.column_number unless kind.nil?
    unrecognized kind "#{kind}" -- currently known options are:
      - telegram
    HERE
    raise JSON::ParseException.new <<-HERE, parser.line_number, parser.column_number
    the "kind" property of every notifier must be specified. Currently available
    options are:
      - telegram
    HERE
  end

  abstract def notify(msg, severity = Severity::Warning)
  abstract def spawn_service(error_channel : Channel(Exception))
end
