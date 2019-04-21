require "./exception"

class Pingas::Failures::ModuleNotFound < Pingas::Failures::Exception
  property msg : String

  def severity
    Severity::Warning
  end

  def initialize(title)
    super @msg = "no module found with title " + title
  end
end
