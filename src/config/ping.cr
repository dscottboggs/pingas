require "./options/*"

module Pingas
  struct Config
    struct Ping
      # The kind of ping this object specifies. The available kinds are:
      #
      # ```
      # http:     A web request.
      # sh:       Run a command in the system's default POSIX-compatible shell.
      # bash:     Run a command in the bash shell.
      # zsh:      Run a command in the zsh shell.
      # fish:     Run a command in the fish shell.
      # python2:  Run a command in the system's default python2 shell.
      # python3:  Run a command in the system's default python3 shell.
      # ruby:     Run a command in the system's default ruby shell.
      # ````
      #
      # Note the lack of a generic "python" shell. This is to avoid confusion
      # between python3 (what should be written by default) and python2 (the
      # shell launched when running the "python" command)
      property kind : String
      property options : Pingas::Config::Options
      delegate :run, to: @options

      def initialize(@kind, @options)
      end

      def to_json(builder : JSON::Builder)
        builder.object do
          builder.field "kind", kind
          builder.field "options", options
        end
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
                          the key "kind" must be specified before the "options" key
                        HERE
                      when "http"
                        HTTPOptions.new parser
                      when "sh",
                           "bash",
                           "zsh",
                           "fish",
                           "python2",
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
