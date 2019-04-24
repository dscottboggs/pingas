require "spec"
require "../src/pingas"

SRC_DIR = File.dirname __DIR__
record Fixture, config_file_loc : String = File.join SRC_DIR, "spec", "data", "config.json"
FIXTURE = Fixture.new
Pingas.config = Pingas::Config.new \
  file_location: FIXTURE.config_file_loc
