Gem::Specification.new do |gem|
  gem.authors     = ['Mauro Rodrigues']
  gem.email       = ['maurorodrigues15@gmail.com']
  gem.description = %q{HashTML is a gem for parsing HTML documents to Ruby Hash-like objects.}
  gem.summary     = %q{A HTML to Hash to HTML helper.}
  gem.homepage    = 'https://github.com/MRod15/hashtml'

  gem.files         = `git ls-files`.split("\n")
  gem.name          = 'hashtml'
  gem.require_paths = ['lib']
  gem.version       = '0.0.2'
  gem.license       = 'MIT'

  gem.add_runtime_dependency('nokogiri', '~> 1.5')

  gem.add_development_dependency('rake', '~> 10.1')
  gem.add_development_dependency('yard', '~> 0.8')
  gem.add_development_dependency('yard-cucumber', '~> 2.3')
  gem.add_development_dependency('kramdown', '~> 1.3')
end
