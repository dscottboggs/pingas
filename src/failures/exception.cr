
abstract class Failures::Exception < ::Exception
  abstract def message
  abstract def severity
  def initialize(@message : String)
    super @message
  end
end

require "./*"
