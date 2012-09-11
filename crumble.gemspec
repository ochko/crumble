$:.push File.expand_path("../lib", __FILE__)
require "crumble/version"

Gem::Specification.new do |s|
  s.name        = "crumble"
  s.version     = Crumble::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = "Lkhagve Ochirkhuyag"
  s.email       = "ochkoo@gmail.com"
  s.homepage    = "http://github.com/ochko/crumble"
  s.summary     = "Breadcrumb for Rails"
  s.description = "How did these breadcrumbs in your Rails application? Oh right, with this plugin!"

  s.files         = %w(README.md Rakefile VERSION lib/crumble.rb lib/crumble/beard.rb lib/crumble/helper.rb lib/crumble/railtie.rb lib/crumble/version.rb)
  s.test_files    = %w(spec/breadcrumb_spec.rb spec/breadcrumbs_helper_spec.rb spec/spec_helper.rb)
  s.require_paths = ["lib"]
end

