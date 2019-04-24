require "../severity"
require "../failures/exception"

struct Pingas::Config
  abstract struct Options
    # abstract def self.from_yaml
    # abstract def to_yaml
    # abstract def self.from_json
    abstract def to_json
    abstract def run
    property severity : Severity { Severity::Warning }
    getter notifier_names : Array(String) { Pingas.config.file.notifiers.keys }

    def notifiers=(names @notifier_names : Array(String))
    end

    def notifiers : Iterator(Notifier)
      notifier_names.map { |id| Pingas.config.file.notifiers[id]? || raise NotifierNotFound.new notifier: id }
    end
  end
end
