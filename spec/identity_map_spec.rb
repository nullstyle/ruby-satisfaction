require File.dirname(__FILE__) + '/spec_helper'

describe "Identity Map" do
  it "should work single instances" do
    c1 = @satisfaction.companies.get(4)
    c2 = @satisfaction.companies.get(4)
    
    c1.object_id.should == c2.object_id
  end
  
  it "should load one if the other gets loaded" do
    c1 = @satisfaction.companies.get(4)
    c2 = @satisfaction.companies.get(4)
    c2.should_not be_loaded
    
    c1.load
  
    c2.should be_loaded
    c2.domain.should == 'satisfaction'
  end
  
  it "should work with pages too" do
    c1 = @satisfaction.companies.get(4)
    c2 = @satisfaction.companies.page(1, :q => 'satisfaction').first
    
    c1.object_id.should == c2.object_id
  end
end