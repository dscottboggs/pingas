require "./failures/exception"
require "./config/entry"

struct Pingas::ConfigFile
  # include YAML::Serializable
  include JSON::Serializable
  property notifiers : Hash(String, Notifier)

  def initialize(@data); end

  def self.new
    new ({} of String => Entry)
  end

  property data : Hash(String, Entry)

  def run(subset : Array(String) = data.keys)
    subset.each do |title|
      if mod = data[title]?
        mod.run
      else
        raise Failures::ModuleNotFound.new title
      end
    end
  rescue e : Failures::Exception
    notify e
  rescue e : ::Exception
    notify "uncaught exception: #{e.message}", severity: Severity::Error
  end

  def notify(message : String,
             selected_notifiers : Array(String) = @notifiers.keys,
             severity = Severity::Info)
    selected_notifiers.each do |nkey|
      if notifier = notifiers[nkey]?
        notifier.notify message, severity
      end
    end
  end

  def notify(exception : Failures::Exception)
    notify exception.message, severity: exception.severity
  end
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
