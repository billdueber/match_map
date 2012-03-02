require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'minitest/spec'
require 'minitest/benchmark'
if RUBY_VERSION =~ /^1.9/
  begin
    require 'turn/autorun'
    f = ENV['format']
    Turn.config.format = f.to_sym
  rescue LoadError
  end
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'match_map'

class MiniTest::Unit::TestCase
end

MiniTest::Unit.autorun
