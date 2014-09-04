require 'hashtml/version'

Gem::Specification.new do |gem|
  gem.authors     = ['Mauro Rodrigues']
  gem.email       = 'maurorodrigues15@gmail.com'
  gem.description = %q{HashTML is a gem for parsing HTML documents to Ruby Hash-like objects.}
  gem.summary     = %q{A HTML to Hash to HTML helper.}
  gem.homepage    = 'https://github.com/MRod15/hashtml'

  gem.files         = Dir.glob('{lib}/**/*')
  gem.name          = 'hashtml'
  gem.require_paths = ['lib']
  gem.version       = HashTML::VERSION
  gem.license       = 'MIT'
  gem.has_rdoc      = 'yard'

  gem.add_runtime_dependency 'nokogiri', '>= 1.5.5'

  gem.add_development_dependency('cucumber', '~> 1.3')
  gem.add_development_dependency('rake', '~> 10.1')
  gem.add_development_dependency('yard', '~> 0.8')
  gem.add_development_dependency('yard-cucumber', '~> 2.3')
  gem.add_development_dependency('kramdown', '~> 1.3')
end