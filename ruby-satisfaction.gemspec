# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby-satisfaction}
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Fleckenstein", "Josh Nichols", "Pius Uzamere"]
  s.date = %q{2009-07-10}
  s.description = %q{Ruby interface to Get Satisfaction}
  s.email = %q{scott@getsatisfaction.com}
  s.extra_rdoc_files = [
    "README.txt"
  ]
  s.files = [
    ".gitignore",
     "CONTRIBUTORS.txt",
     "License.txt",
     "README.txt",
     "Rakefile",
     "VERSION.yml",
     "init.rb",
     "lib/satisfaction.rb",
     "lib/satisfaction/associations.rb",
     "lib/satisfaction/cache/hash.rb",
     "lib/satisfaction/cache/memcache.rb",
     "lib/satisfaction/company.rb",
     "lib/satisfaction/external_dependencies.rb",
     "lib/satisfaction/has_satisfaction.rb",
     "lib/satisfaction/identity_map.rb",
     "lib/satisfaction/loader.rb",
     "lib/satisfaction/person.rb",
     "lib/satisfaction/product.rb",
     "lib/satisfaction/reply.rb",
     "lib/satisfaction/resource.rb",
     "lib/satisfaction/resource/attributes.rb",
     "lib/satisfaction/tag.rb",
     "lib/satisfaction/topic.rb",
     "lib/satisfaction/util.rb",
     "ruby-satisfaction.gemspec",
     "spec/company_spec.rb",
     "spec/identity_map_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/nullstyle/ruby-satisfaction}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{satisfaction}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Ruby interface to Get Satisfaction}
  s.test_files = [
    "spec/company_spec.rb",
     "spec/identity_map_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<memcache-client>, [">= 1.5.0"])
      s.add_runtime_dependency(%q<oauth>, [">= 0.3.5"])
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.2"])
    else
      s.add_dependency(%q<memcache-client>, [">= 1.5.0"])
      s.add_dependency(%q<oauth>, [">= 0.3.5"])
      s.add_dependency(%q<activesupport>, [">= 2.3.2"])
    end
  else
    s.add_dependency(%q<memcache-client>, [">= 1.5.0"])
    s.add_dependency(%q<oauth>, [">= 0.3.5"])
    s.add_dependency(%q<activesupport>, [">= 2.3.2"])
  end
end
