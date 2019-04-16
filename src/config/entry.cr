module Pingas
  struct ConfigFile
    struct Entry
      property kind : String
      property options : Pingas::ConfigFile::Options
      property notifiers : Array(String)

      def self.new(pull parser : JSON::Serializable)
        kind, options = nil
        parser.read_object do |key|
          case key
          when "kind" then kind = parser.read_string
          when "options"
            options = case k = kind
                      when nil
                        # TODO this is a bit of a hack....
                        parser.raise %<"kind" must be specified before "options">
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
                        parser.raise %<unrecognized "kind": #{kind}>
                      end
          end
        end
      end

      def to_yaml(builder : YAML::Builder)
      end
    end
  end
end
