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
        errors.send e
      rescue e : ::Exception
        errors.send Failures::UncaughtException.new e, severity: Severity::Error
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

  ERR_BUFSIZE = 6
  class_property errors : Channel(Exception) do
    Channel(Exception).new ERR_BUFSIZE
  end

  {% unless env("SPEC") %}
    # don't start the service loop if running the specs
    Pingas.config.file.notifiers.each { |k, n| n.spawn_service error_channel: errors }
    loop do
      sleep 10.seconds
      run
    end
  {% end %}
end
