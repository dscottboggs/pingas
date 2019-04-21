require "spec"
require "../src/pingas"

SRC_DIR = File.dirname __DIR__
Pingas.config = Pingas::Config.new \
  file_location: File.join(SRC_DIR, "spec", "data", "config.json")
