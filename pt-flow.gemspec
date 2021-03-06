# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pt-flow/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jens Balvig"]
  gem.email         = ["jens@balvig.com"]
  gem.description   = %q{Some extra methods for the pt gem to use in our dev flow.}
  gem.summary       = %q{Some extra methods for the pt gem to use in our dev flow.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "pt-flow"
  gem.require_paths = ["lib"]
  gem.version       = PT::Flow::VERSION

  gem.add_dependency 'pt'
  gem.add_dependency 'hub'
  gem.add_dependency 'pivotal-tracker'
  gem.add_dependency 'activesupport'
  gem.add_dependency 'hirb-colors'
  gem.add_dependency 'trollop', '~> 2.1'

  gem.add_development_dependency 'rspec', '~> 2.9'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'rake'
end
