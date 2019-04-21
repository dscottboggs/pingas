require "./failures/exception"
require "./config/**"

struct Pingas::Config
  module Defaults
    extend self

    def file_location : String
      ENV["PINGAS_CONFIG_FILE"]? ||
        ENV["XDG_CONFIG_HOME"]?.try do |path|
          ::File.join(path, "pingas", "config.json")
        end ||
        ENV["HOME"]?.try do |path|
          ::File.join(path, ".config", "pingas", "config.json")
        end || ::File.join("/home", ENV["USER"], ".config", "pingas", "config.json")
    end

    def granularity
      10.seconds
    end
  end

  property file_location : String { Defaults.file_location }
  property file : Config::File do
    ::File.open file_location do |file_io|
      Config::File.from_json file_io
    end
  end
  property granularity : Time::Span { Defaults.granularity }

  HELP_TEXT = <<-HERE
    Pingas: Ping your services for health and status.

  Usage: pingas [options]

  Options:
      -h, --help, help            Display this help message.
      -f, --config-file           The location of the config file.
          Default:                #{Defaults.file_location}
      -g, --granularity           The number of seconds between pings.
  HERE

  def initialize(@file_location = Defaults.file_location,
                 @granularity = Defaults.granularity)
  end

  def self.from_args(args = ARGV)
    config = new
    while arg = args.shift?
      case arg
      when "-f", "--config-file" then config.file_location = args.shift
      when .starts_with? "--config-file"
        config.file_location = arg["--config-file=".size..]
      when "-g", "--granularity" then config.granularity = args.shift.to_i.seconds
      when .starts_with?("-g")   then config.granularity = arg[2..].to_i.seconds
      when .starts_with? "--granularity"
        config.granularity = arg["--granularity=".size..].to_i.seconds
      when "-h", "--help", "help"
        STDERR.puts HELP_TEXT
        exit 0
      else
        puts "unrecognized option #{arg}"
      end
    end
    config
  end
end
