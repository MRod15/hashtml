require File.join(File.dirname(__FILE__), 'lib', 'hashtml', 'version')

Gem::Specification.new do |gem|
  gem.authors     = ["Mauro Rodrigues"]
  gem.email       = ["maurorodrigues15@gmail.com"]
  gem.description = %q{HashTML is a gem for parsing HTML documents to Ruby Hash-like objects.}
  gem.summary     = %q{A HTML to Hash to HTML helper.}
  gem.homepage    = 'https://github.com/MRod15/hashtml'

  gem.files         = `git ls-files`.split("\n")
  gem.name          = "hashtml"
  gem.require_paths = ['lib']
  gem.version       = HashTML::VERSION
  gem.license       = "MIT"

  gem.add_dependency 'nokogiri', '~> 1.5.5'
end