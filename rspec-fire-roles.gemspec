# encoding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rspec/fire/roles/version"

Gem::Specification.new do |gem|
  gem.name          = "rspec-fire-roles"
  gem.version       = RSpec::Fire::Roles::VERSION
  gem.authors       = ["Chris Vincent"]
  gem.email         = ["c.j.vincent@gmail.com"]
  gem.description   = %q{Mock roles, not objects. For use with rspec-fire.}
  gem.summary       = gem.description
  gem.homepage      = "http://github.com/cvincent/rspec-fire-roles"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "cucumber"
  gem.add_development_dependency "aruba"

  gem.add_dependency "rspec-fire"
end
