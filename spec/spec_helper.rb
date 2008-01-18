require 'rubygems'
require 'spec'
$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'satisfaction'

Spec::Runner.configure do |config|
  config.prepend_before(:each){ @satisfaction = Satisfaction.new(:root => 'http://localhost:3000') }
end