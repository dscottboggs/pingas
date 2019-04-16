struct Pingas::ConfigFile
  struct HTTPOptions
    property url : URI
    property method : String
    property body : String?

    def initialize(@path, @method, @body); end

    def self.new(pull parser : JSON::PullParser)
      path, method, body = nil, nil, nil
      parser.read_object do |key|
        case key
        when "path"   then url = URI.parser parser.read_string
        when "method" then method = parser.read_string
        when "body"   then body = parser.read String?
        else               parser.raise %<unrecognized key "#{key}">
        end
      end
      {% for key in [:path, :method] %}
      parser.raise %<expected key "{{key.id}}" to be found in options of kind "http"> if {{key.id}}.nil?
      {% end %}
      new path.not_nil!, method.not_nil!, body
    end

    private property http_client : HTTP::Client { HTTP::Client.new url }

    def finalize
      http_client.close
    end

    def query
      if url.query.empty?
        ""
      else
        "?" + url.query
      end
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
            raise Failures::HTTP.new url, response
          end
        end
      end
    end
  end
end
