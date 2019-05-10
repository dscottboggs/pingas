require "../severity"
require "./exception"

# An error raised when a notifier kind is configured but no such type exists.
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
