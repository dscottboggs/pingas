require "./options/*"

module Pingas
  struct Config
    struct Ping
      property kind : String
      property options : Pingas::Config::Options
      delegate :run, to: @options

      def initialize(@kind, @options)
      end

      def self.new(pull parser : JSON::PullParser)
        kind, options = nil, nil
        lin, col = parser.line_number, parser.column_number
        parser.read_object do |key|
          case key
          when "kind" then kind = parser.read_string
          when "options"
            options = case k = kind
                      when nil
                        # TODO this is a bit of a hack....
                        raise JSON::ParseException.new <<-HERE, lin, col
                          the key "kind" must be specified before the "options" key.
                        HERE
                      when "http"
                        HTTPOptions.new parser
                      when "sh",
                           "bash",
                           "zsh",
                           "fish",
                           "python",
                           "python3",
                           "ruby"
                        ShellOptions.new parser, shell: k
                      else
                        raise JSON::ParseException.new "unrecognized ping type #{kind}", lin, col
                      end
          end
        end

        raise JSON::ParseException.new "options key is required", lin, col if options.nil?
        raise JSON::ParseException.new "kind is required", lin, col if kind.nil?
        new kind.not_nil!, options.not_nil!
      end

      def to_yaml(builder : YAML::Builder)
      end
    end
  end
end
