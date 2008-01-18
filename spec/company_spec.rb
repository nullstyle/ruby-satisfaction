require 'spec_helper'

describe "Company loader" do
  it "should work" do
    p @satisfaction.companies.get("satisfaction").topics
    t = @satisfaction.topics.get("256")
    p t.last_active_at
    p t.attributes
    
  end
end