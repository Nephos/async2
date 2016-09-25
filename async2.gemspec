# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "async2/version"

Gem::Specification.new do |s|
  s.name        = "async2"
  s.version     = Async2::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Arthur Poulet"]
  s.email       = ["arthur.poulet@mailoo.org"]
  s.homepage    = "https://github.com/Nephos/async2"
  s.summary     = %q{Asynchronous concurrent stuff lib.}
  s.description = %q{Asynchronous concurrent stuff lib. IO and HTTP layers.}

  s.add_development_dependency "rspec", "~> 2.5"
  s.add_development_dependency 'nomorebeer', '~> 1.1', '>= 1.1.1'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.license     = 'WTFPL'

  s.cert_chain  = ['certs/nephos.pem']
  s.signing_key = File.expand_path('~/.ssh/gem-private_key.pem') if $0 =~ /gem\z/

end
