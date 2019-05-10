class URI
  def to_json(builder : JSON::Builder)
    builder.string self.to_s
  end
  def self.from_json(pull parser : JSON::PullParser)
    URI.parse parser.read_string
  end
end
