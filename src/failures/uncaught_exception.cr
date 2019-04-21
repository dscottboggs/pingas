class Pingas::Failures::UncaughtException < Pingas::Failures::Exception
  @backing : ::Exception
  property severity : Severity
  getter msg : String { @backing.message || "exception of type #{@backing.class}" }

  def initialize(@backing, @severity)
  end
end
