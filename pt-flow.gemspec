# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pt-flow/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jens Balvig"]
  gem.email         = ["jens@cookpad.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "pt-flow"
  gem.require_paths = ["lib"]
  gem.version       = PT::Flow::VERSION

  gem.add_dependency 'pt'
  gem.add_dependency 'git_tracker'
end
