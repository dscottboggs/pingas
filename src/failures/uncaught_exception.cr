# A failure to be raised when an arbitrary exception was raised in the process
# of trying to run a pinger or send a notification. This kind of Failure
# generally indicates a bug of some sort.
class Pingas::Failures::UncaughtException < Pingas::Failures::Exception
  @backing : ::Exception
  property severity : Severity
  getter msg : String { @backing.message || "exception of type #{@backing.class}" }

  def initialize(@backing, @severity)
  end
end
