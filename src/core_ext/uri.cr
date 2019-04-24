class URI
  def to_json(builder : JSON::Builder)
    builder.string self.to_s
  end
end
