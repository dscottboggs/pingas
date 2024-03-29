require "../options"

# Options for a pinger which runs a given command in the specified shell.
struct Pingas::Config::ShellOptions < Pingas::Config::Options
  # The shell to run the command in.
  #
  # For example:
  # ```json
  # "kind": "sh",
  # "options": {
  #   "command": "systemctl status someservice"
  # },
  # "kind": "python3",
  # "options": {
  #   "command": "print('whatever shell you want')"
  # }
  # ```
  property shell : String
  # The text to pass to the shell.
  property command : String
  # The output status of the command. TODO allow Range or Set.
  property status : UInt8
  # The expected output of the shell script. TODO allow Regex.
  property output : String?
  # The expected stderr output of the shell script. TODO allow Regex.
  property error : String?
  # Text to pass to the shell script on stdin
  property input : String?
  # Any environment variables that need specified to the command.
  property env : Hash(String, String)
  # The working directory in which to launch the command.
  property workdir : String?

  def initialize(@shell,
                 @command,
                 @status,
                 @output = nil,
                 @error = nil,
                 @input = nil,
                 @env = {} of String => String,
                 @workdir = nil,
                 @severity = Severity::Warning,
                 @notifier_names = nil)
  end

  # Parse a ShellOptions from it's options value. This Options object must have
  # been found directly beneath a "kind" key that lists a known and installed
  # shell.
  #
  # Due to the many branches necessary to parse a JSON text, this method is
  # inherently cyclomatically complex.
  #
  # ameba:disable Metrics/CyclomaticComplexity
  def self.new(pull parser : JSON::PullParser, *, shell : String = "bash")
    command = nil
    status = 0u8
    output = nil
    error = nil
    input = nil
    env = {} of String => String
    workdir = nil
    severity = Severity::Warning
    notifiers = nil
    parser.read_object do |key|
      case key
      when "command"  then command = parser.read_string
      when "status"   then status = parser.read_int.to_u8!
      when "output"   then output = parser.read_string
      when "error"    then error = parser.read_string
      when "input"    then input = parser.read_string
      when "env"      then env.merge! Hash(String, String).new parser
      when "workdir"  then workdir = parser.read_string
      when "severity" then severity = Severity.new parser
      when "notifiers"
        n = [] of String
        parser.read_array do
          n << parser.read_string
        end
        notifiers = n
      else
        raise JSON::ParseException.new %<unrecognized key "#{key}">, parser.line_number, parser.column_number
      end
    end
    raise JSON::ParseException.new %<key "command" must be specified>, parser.line_number, parser.column_number if command.nil?
    new shell, command.not_nil!, status, output, error, input, env, workdir, severity, notifiers
  end

  def formatted_command
    if shell == "ruby"
      "ruby -e " + '"' + command.gsub(%<">, %<\\">) + '"'
    else
      shell + " -c \"" + command.gsub(%<">, %<\\">) + '"'
    end
  end

  def fail!(*, exit : Int32)
    raise Failures::SpawnedProcessFailure.new <<-HERE, severity
    Failure in spawned #{shell} process:
    Expected exit status #{status} but received #{exit}.
    Command:
      #{command}
    HERE
  end

  def fail!(*, exit : Signal)
    raise Failures::SpawnedProcessFailure.new <<-HERE, severity
    Failure in spawned #{shell} process:
    The command received and didn't handle signal #{exit}.
    Command:
      #{command}
    HERE
  end

  def fail!(*, output : String, expected : String)
    # TODO: add diffing?
    raise Failures::SpawnedProcessFailure.new <<-HERE, severity
    Failure in spawned #{shell} process:
    The process was expected to output "#{expected}", but instead it output
    #{output}.
    Command:
      #{command}
    HERE
  end

  def fail!(*, error : String, expected : String, output : String? = nil)
    # TODO: add diffing?
    raise Failures::SpawnedProcessFailure.new <<-HERE, severity
    Failure in spawned #{shell} process:
    The process was expected to output "#{expected}" to stderr, but instead it
    output #{error}. #{"output on stdout was " + output unless output.nil?}
    Command:
      #{command}
    HERE
  end

  def run
    opipe, epipe = IO::Memory.new, IO::Memory.new
    process = Process.new formatted_command,
      shell: true,
      env: env,
      chdir: workdir,
      output: opipe,
      error: epipe
    if input_data = input
      process.input << input_data
    end
    result = process.wait
    if result.normal_exit? && result.exit_code == status
      actual_ouput = opipe.gets_to_end
      if expected_output = output
        if expected_output != actual_ouput
          fail! output: actual_ouput, expected: expected_output
        end
      end
      if expected = error
        if expected != (actual = epipe.gets_to_end)
          fail! error: actual, expected: expected, output: actual_ouput
        end
      end
    elsif result.signal_exit?
      fail! exit: result.exit_signal
    else
      fail! exit: result.exit_code
    end
  end

  def to_json(io : IO)
    JSON.build io do |builder|
      to_json builder
    end
  end

  def to_json(builder : JSON::Builder)
    builder.object do
      builder.field "notifiers", notifier_names
      builder.field "env", env unless env.empty?
      builder.field "severity", severity.to_s unless severity == Severity::Warning
      {% for ivar in @type.instance_vars.reject { |v| [:notifier_names.id, :env.id, :severity.id, :shell.id].includes? v.name } %}
      builder.field "{{ivar.name}}", {{ivar}} if {{ivar}}
      {% end %}
    end
  end
end
