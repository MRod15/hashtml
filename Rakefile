# encoding: utf-8
require 'yard'
require 'rake/testtask'
require 'cucumber'
require 'cucumber/rake/task'
task :default => 'hashtml:yard'

namespace :hashtml do
  YARD::Rake::YardocTask.new do |t|
    t.files = %w[lib/**/*.rb features/**/*.feature features/**/*.rb - README.md]
    t.options = %w(-M kramdown)
  end
end
