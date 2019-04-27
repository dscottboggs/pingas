require "./core_ext/**"
require "./config"
require "./failures/exception"
require "./notifier"

# TODO: Write documentation for `Pingas`
module Pingas
  VERSION = "0.1.0"

  class_property config : Config { Config.from_args }

  extend self

  def run(subset : Array(String) = Pingas.config.file.pings.keys)
    subset.each do |title|
      spawn do
        if (mod = Pingas.config.file.pings[title]?).nil?
          notify Failures::ModuleNotFound.new title
        else
          mod.run
        end
      rescue e : Failures::Exception
        puts "got failure " + e.msg
        failures.send e
      rescue e : ::Exception
        failures.send Failures::UncaughtException.new e, severity: Severity::Error
      end
    end
  end

  def notify(message : String,
             selected_notifiers : Array(String) = Pingas.config.file.notifiers.keys,
             severity = Severity::Info)
    selected_notifiers.each do |nkey|
      if notifier = Pingas.config.file.notifiers[nkey]?
        notifier.notify message, severity
      end
    end
  end

  def notify(exception : Failures::Exception)
    notify exception.msg, severity: exception.severity
  end

  # Return with a reply message to the given text message, or nil to not
  # respond.
  def self.handle(message : String) : String?
    # TODO define
    nil
  end

  ERR_BUFSIZE = {{ env("ERR_BUFSIZE") }} || ENV["ERR_BUFSIZE"]?try(&.to_i!) || 6
  class_property failures : Channel(Failures::Exception) do
    Channel(Failures::Exception).new ERR_BUFSIZE
  end
  class_property errors : Channel(Exception) do
    Channel(Exception).new ERR_BUFSIZE
  end

  # Notify the user of failures according to the configured rules.
  spawn { loop { notify failures.receive } }

  # Notify the user of any uncaught errors
  spawn do
    loop do
      notify Failures::UncaughtException.new errors.receive, severity: Severity::Error
    end
  end

  {% unless env("SPEC") %}
    # don't start the service loop if running the specs
    Pingas.config.file.notifiers.each { |k, n| spawn {n.spawn_service error_channel: errors} }
    loop do
      Fiber.yield
      sleep 10.seconds
      run
    end
  {% end %}
end
