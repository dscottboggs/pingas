require "./spec_helper"

describe Pingas do
  it "has a notifier" do
    Pingas.config.file.notifiers.size.should be > 0
  end
  it "has pingers" do
    Pingas.config.file.pings.size.should be > 1
  end
end
