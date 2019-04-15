
struct Pingas::ConfigFile
  struct HTTPOptions
    property path : String
    property method : HTTPVerb
    property body : String
    def initialize(@path, @method, @body); end
    def self.new(pull parser : JSON::PullParser)
      path, method, body = nil, nil, nil
      parser.read_object do |key|
        case key
        when "path" then path = parser.read_string
        when "method" then method = HTTPVerb.new parser
        when "body" then body = parser.read_string
        else parser.raise %<unrecognized key "#{key}">
      end
      {% for key in [:path, :method, :body] %}
      parser.raise %<expected key "{{key.id}}" to be found in options of kind "http"> if {{key.id}}.nil?
      {% end %}
      new path.not_nil!, method.not_nil!, body.not_nil!
    end
  end
end
