require "../severity"

class Pingas::Failures::SpawnedProcessFailure < Pingas::Failures::Exception
  property msg : String
  property severity : Severity

  def initialize(@msg : String, @severity)
    super @msg
  end
end
