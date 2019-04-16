class Pingas::Failures::ModuleNotFound < Exception
  property message : String
  def severity
    Severity::Warning
  end
  def initialize(title)
    super @message = "no module found with title " + title
  end
end
