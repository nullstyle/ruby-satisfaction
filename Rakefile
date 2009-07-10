begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "ruby-satisfaction"
    gemspec.summary = "Ruby interface to Get Satisfaction"
    gemspec.description = "Ruby interface to Get Satisfaction"
    gemspec.email = "scott@getsatisfaction.com"
    gemspec.homepage = "http://github.com/nullstyle/ruby-satisfaction"
    gemspec.authors = ["Scott Fleckenstein", "Josh Nichols", "Pius Uzamere"]
    gemspec.rubyforge_project = "satisfaction"
    gemspec.add_dependency('memcache-client', '>= 1.5.0')
    gemspec.add_dependency('oauth', '>= 0.3.5')
    gemspec.add_dependency('activesupport', '>= 2.3.2')
  end
  
  Jeweler::RubyforgeTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end