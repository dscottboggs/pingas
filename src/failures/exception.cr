abstract class Pingas::Failures::Exception < ::Exception
  abstract def msg
  abstract def severity
end

require "./*"
