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
  gem.required_ruby_version = '>= 1.9.0' # due to use of define_singleton_method in optimize
  gem.name = "match_map"
  gem.homepage = "http://github.com/billdueber/match_map"
  gem.license = "MIT"
  gem.summary = "A multimap that allows keys to match regex patterns"
  gem.description = %Q{MatchMap is a map representing key=>value pairs but where 
    (a) a query argument can match more than one key, and (b) the argument is compraed to the key
    such that you can use regex patterns as keys}
  gem.email = "bill@dueber.com"
  gem.authors = ["Bill Dueber"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

desc "Run a quick benchmark"
task :bench do
  $: << 'lib'
  load 'bench/bench.rb'
end

task :default => :test

require 'yard'
YARD::Rake::YardocTask.new
