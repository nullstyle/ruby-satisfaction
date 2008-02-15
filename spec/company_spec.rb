require 'spec_helper'

describe "Company loader" do
  it "should work" do
    @satisfaction.set_consumer('lmwjv4kzwi27', 'fiei6iv61jnoukaq1aylwd8vcmnkafrs')
    p @satisfaction.request_token
  end
end