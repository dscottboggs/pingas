require "../spec_helper"

describe Pingas::Config::File do
  it "has a notifier" do
    Pingas.config.file.notifiers.size.should be > 0
  end
  it "has pingers" do
    Pingas.config.file.pings.size.should be > 1
  end
  describe "#to_json" do
    it "serializes the same values that it deserializes" do
      JSON.parse(Pingas.config.file.to_json(indent: 2).tap { |json| puts "json => #{json}" })
        .should eq JSON.parse File.read(FIXTURE.config_file_loc)
    end
  end
end
