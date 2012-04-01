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
creating = false

unless Rdy.new(RDY_SIMPLE_TABLE, [:id, :string]).table_exists?
  puts "Setting up test tables for Rdy: #{RDY_SIMPLE_TABLE}"
  Rdy.create_table(RDY_SIMPLE_TABLE, 3, 5, :id => :string)
  creating = true
end

unless Rdy.new(RDY_RANGE_TABLE, [:id, :string], [:foo, :string]).table_exists?
  puts "Setting up test tables for Rdy: #{RDY_RANGE_TABLE}"
  Rdy.create_table(RDY_RANGE_TABLE, 3, 5, {:id => :string}, {:foo => :string})
  creating = true
end

if creating
  puts "Waiting for tables to become active..."
  sleep 60
end

class Test::Unit::TestCase
end
