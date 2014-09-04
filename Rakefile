# encoding: utf-8
require 'yard'
require 'rake/testtask'
require 'cucumber'
require 'cucumber/rake/task'

task :default => 'hashtml:run_tests'

namespace :hashtml do
  def load_dependencies(task)
    task.libs << File.join(File.dirname(__FILE__), 'lib')
  end

  Rake::TestTask.new(:test) do |test|
    load_dependencies(test)
    test.libs << 'lib' << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end

  Cucumber::Rake::Task.new 'run_tests', 'run hashtml tests' do |task|
    load_dependencies(task)
  end

  YARD::Rake::YardocTask.new do |t|
    t.files   = %w[lib/**/*.rb features/**/*.feature features/**/*.rb - README.md]
    t.options = %w(-M kramdown)
  end
end