# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pdns/remotebackend/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Aki Tuomi"]
  gem.email         = ["cmouse@desteem.org"]
  gem.description   = %q{This gem provides a base class and helpers for writing remotebackend servers for pipe/unix/. It is intended to make using remotebackend easier. For http support, see pdns-remotebackend-http.}
  gem.summary       = %q{This gem provides a base class and helpers for writing remotebackend servers for pipe/unix/http post/json modes}
  gem.homepage      = "http://github.com/cmouse/pdns-remotebackend"
  gem.license       = "MIT"
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "pdns-remotebackend"
  gem.require_paths = ["lib"]
  gem.version       = Pdns::Remotebackend::VERSION

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_runtime_dependency 'json'
end
