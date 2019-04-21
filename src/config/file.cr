require "json"
require "./ping"
require "../notifier"

struct Pingas::Config
  struct File
    # include JSON::Serializable
    def self.new(from_json parser : JSON::PullParser)
      nset, pset = false, false
      notifiers = uninitialized Hash(String, Notifier)
      pings = uninitialized Hash(String, Ping)
      parser.read_object do |key|
        case key
        when "notifiers"
          notifiers = Hash(String, Notifier).new parser
          nset = true
        when "pings"
          pings = Hash(String, Ping).new parser
          pset = true
        end
      end
      raise JSON::ParseException.new "notifers must be set", parser.line_number, parser.column_number unless nset
      raise JSON::ParseException.new "pings must be set", parser.line_number, parser.column_number unless pset
      new notifiers, pings
    end
    property notifiers : Hash(String, Notifier)
    property pings : Hash(String, Ping)

    def initialize(@notifiers = {} of String => Notifier,
                   @pings = {} of String => Ping)
    end
  end
end
