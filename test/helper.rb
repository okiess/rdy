require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rdy'

RDY_SIMPLE_TABLE = 'rdy_test_simple'
RDY_RANGE_TABLE = 'rdy_test_range'

puts "Setting up test tables for Rdy..."
Rdy.create_table(RDY_SIMPLE_TABLE, 10, 5, :id => :string) rescue nil
Rdy.create_table(RDY_RANGE_TABLE, 10, 5, {:id => :string}, {:foo => :string}) rescue nil

class Test::Unit::TestCase
end
