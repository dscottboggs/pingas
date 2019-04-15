abstract struct Pingas::ConfigFile::Options
  abstract def self.from_yaml
  abstract def to_yaml
end
