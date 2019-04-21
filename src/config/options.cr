require "../severity"
require "../failures/exception"

struct Pingas::Config
  abstract struct Options
    # abstract def self.from_yaml
    # abstract def to_yaml
    # abstract def self.from_json
    abstract def to_json
    abstract def run
  end
end
