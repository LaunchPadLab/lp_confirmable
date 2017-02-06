lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lp_confirmable/version'

Gem::Specification.new do |s|
  s.name        = 'lp_confirmable'
  s.version     = LpConfirmable::VERSION
  s.date        = '2017-02-03'
  s.summary     = 'Confirm!'
  s.description = 'A simple confirmable logic'
  s.authors     = ['Dave Corwin']
  s.email       = 'dave@launchpadlab.com'
  s.homepage    = 'https://github.com/launchpadlab/lp_confirmable'
  s.license     = 'MIT'
  s.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
end
