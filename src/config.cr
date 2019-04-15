struct Pingas::ConfigFile
  struct Entry
    property kind : String
    property options : Pingas::ConfigFile::Options

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

  # include YAML::Serializable
  include JSON::Serializable

  def initialize(@data); end

  def self.new
    new [] of Entry
  end

  property data : Array(Entry)
  # def to_yaml(io : IO)
  #   YAML.build io do |builder|
  #     to_yaml builder
  #   end
  #   io
  # end
  # def to_yaml(builder : YAML::Builder)
  #   builder.sequence do
  #     data.to_yaml builder
  #   end
  # end
  # def self.new(pull parser : YAML::PullParser)
  #   instance = new
  #   parser.read_sequence do
  #     while parser.kind.scalar?
  #       instance.data << Entry.new parser
  #     end
  #   end
  #   instance
  # end
end
