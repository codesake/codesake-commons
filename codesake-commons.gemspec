# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'codesake/commons/version'

Gem::Specification.new do |gem|
  gem.name          = "codesake-commons"
  gem.version       = Codesake::Commons::VERSION
  gem.authors       = ["Paolo Perego"]
  gem.email         = ["paolo@codesake.com"]
  gem.description   = %q{codesake.com is an application security startup providing code review and penetration test services for Ruby powered web applications. codesake_commons is the gem containing common ground routines useful across the project}
  gem.summary       = %q{codesake_commons is the gem containing common ground routines useful across the codesake.com project}
  gem.homepage      = "http://codesake.com"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency 'rainbow', '~> 2.0.0'
  gem.add_dependency 'mechanize'
  gem.add_dependency 'nokogiri'
end
