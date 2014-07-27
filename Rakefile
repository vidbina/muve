require "rspec/core/rake_task"
require "rake/testtask"
require "bundler/gem_tasks"
require "rdoc/task"

RSpec::Core::RakeTask.new('spec') do |t|
  t.verbose = false
end

RDoc::Task.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include("lib/**/*.rb")
end

task default: :spec
