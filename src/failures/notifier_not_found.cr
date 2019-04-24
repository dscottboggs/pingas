require "../severity"
require "./exception"

class Pingas::Failures::NotifierNotFound < Pingas::Failures::Exception
  property notifier : String
  getter msg : String { %[notifier with ID "#{@notifier}" not found.] }

  def severity
    Severity::Error
  end

  def initialize(@notifier)
    super msg
  end
end
