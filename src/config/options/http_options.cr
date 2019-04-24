require "http"
require "../options"

# TODO: Close HTTP client!
struct Pingas::Config
  struct HTTPOptions < Options
    property url : URI
    property method : String
    property body : String?

    def initialize(@url,
                   @method,
                   @body,
                   @severity,
                   notifiers @notifier_names = nil)
    end

    def self.new(pull parser : JSON::PullParser)
      path, method, body = nil, nil, nil
      severity = Severity::Warning
      notifiers = nil
      parser.read_object do |key|
        case key
        when "path"     then path = URI.parse parser.read_string
        when "method"   then method = parser.read_string
        when "body"     then body = parser.read_string
        when "severity" then severity = Severity.new parser
        when "notifiers"
          n = [] of String
          parser.read_array do
            n << parser.read_string
          end
          notifiers = n
        else
          raise JSON::ParseException.new <<-HERE, parser.line_number, parser.column_number
          unrecognized option "#{key}" for options of an HTTP-kind ping.
          HERE
        end
      end
      {% for key in [:path, :method] %}
      raise JSON::ParseException.new <<-HERE, parser.line_number, parser.column_number if {{key.id}}.nil?
      the option "{{key.id}}" is required for the options of an HTTP-kind ping.
      HERE
      {% end %}
      new path.not_nil!, method.not_nil!, body, severity, notifiers || Pingas.config.file.notifiers.keys
    end

    def to_json(builder : JSON::Builder)
      builder.object do
        builder.field "path", url
        builder.field "method", method
        builder.field "body", body if body
        builder.field "notifiers", notifier_names
        builder.field "severity", severity.to_s unless severity == Severity::Warning
      end
    end

    private property http_client : HTTP::Client { HTTP::Client.new url }

    def query
      if query = url.query
        unless query.empty?
          return "?" + query
        end
      end
      ""
    end

    def run
      future do
        http_client.exec method: method, path: url.path + query, body: body do |response|
          if response.success?
            <<-HERE
            #{url.to_s} responded with successful "#{response.status_message}".
            Body: #{response.body?}
            HERE
          else
            raise Failures::HTTP.new url, response, severity
          end
        end
      end
    end
  end
end
