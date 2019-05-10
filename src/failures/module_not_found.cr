require "./exception"

# An error raised when a pinger kind is configured but no such type exists.
class Pingas::Failures::PingerNotFound < Pingas::Failures::Exception
  property msg : String

  def severity
    Severity::Warning
  end

  def initialize(title)
    super @msg = "no module found with title " + title
  end
end
