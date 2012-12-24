require 'rubygems'
require 'rake'

begin
  require 'jeweler2'
  Jeweler::Tasks.new do |gem|
    gem.name = "rack-flash3"
    gem.summary = "Flash hash implementation for Rack apps."
    gem.description = "Flash hash implementation for Rack apps."
    gem.email = "treeder@gmail.com"
    gem.homepage = "http://www.iron.io"
    gem.authors = ["Pat Nakajima", "Travis Reeder"]
    gem.add_dependency 'rack'
    gem.add_development_dependency 'rake'
    # gem.required_ruby_version = '>= 1.9'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler2"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test
