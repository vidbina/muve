require "rspec/core/rake_task"
require "rake/testtask"
require "bundler/gem_tasks"

RSpec::Core::RakeTask.new('spec') do |t|
  t.verbose = false
end

Rake::TestTask.new do |t|
  t.libs << 'test'
end

task default: :spec
