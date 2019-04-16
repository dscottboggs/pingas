struct Pingas::ConfigFile::ShellOptions
  property shell : String
  property command : String
  property status : UInt8
  property output : String?
  property error : String?
  property input : String?
  def initialize(@shell, @command, @status, @output = nil, @error = nil, @input = nil); end
  def self.new(pull parser : JSON::PullParser, *, shell : String = "bash")
    command = nil
    status = nil
    output = nil
    error = nil
    input = nil
    parser.read_object do |key|
      case key
      when "command" then command = parser.read_string
      when "status" then status = parser.read_int.to_u8
      when "output" then output = parser.read? String
      when "error" then error = parser.read? String
      when "input" then input = parser.read? String
      else parser.raise %<unrecognized key "#{key}">
    end
    parser.raise %<expected key "command" to be found in options of kind "#{shell}"> if command.nil?
    parser.raise %<expected key "status" to be found in options of kind "#{shell}"> if command.nil?
    new shell, command.not_nil!, status.not_nil!, output, error, input
  end
  def to_json(io : IO)
    JSON.build io do |builder|
      to_json builder
    end
  end
  def to_json(builder : JSON::Builder)
    builder.object do
      {% for ivar in @type.instance_vars %}
      builder.field "{{ivar.name}}", {{ivar}} if {{ivar}}
      {% end %}
    end
  end
end
