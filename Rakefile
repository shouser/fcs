# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "fcs"
  gem.homepage = "http://github.com/TiltingAt/fcs"
  gem.license = "MIT"
  gem.summary = %Q{Final Cut Server offers a command line interface to much of it's functionality.   This gem offers a more ruby'ish interface to that functionality.}
  gem.description = %Q{}
  gem.email = "steve@tilting.at"
  gem.authors = ["Tilting @, LLC"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)

#task :default => :spec

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "fcs #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :test => [:spec, :features] 

task :default => :test

# PRIVATE GEM: Remove tasks for releasing this gem to Gemcutter
tasks = Rake.application.instance_variable_get('@tasks')
tasks.delete('release')
tasks.delete('gemcutter:release')
