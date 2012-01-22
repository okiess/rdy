require "rubygems"
gem "aws-sdk"
require "aws-sdk"

class Rdy
  RESERVED = ["attributes", "hash_value", "hash_key", "is_new?", "all", "find", "save",
    "create_table", "table", "table=", "destroy", "dynamodb"]

  def initialize(table, hash_key)
    @attributes = {}; @table = table; @hash_key = hash_key; @is_new = true
    @_table = Rdy.dynamo_db.tables[@table]
    @_table.status
  end

  def table=(value); @table = value; end
  def table; @table; end
  def attributes; @attributes; end
  def hash_value; @hash_value; end
  def hash_key; @hash_key; end
  
  def self.dynamo_db
    config = YAML.load(File.read("#{ENV['HOME']}/.rdy.yml"))
    raise "Config file expected in ~/.rdy.yml" unless config
    @@dynamo_db = AWS::DynamoDB.new(:access_key_id => config['access_key_id'],
                                   :secret_access_key => config['secret_access_key'])
  end

  def self.create_table(table, read_capacity_units, write_capacity_units, hash_key, range_key = nil)
    dynamo_db.tables.create(table, read_capacity_units, write_capacity_units,
      :hash_key => hash_key, :range_key => range_key)
  end

  def all; @_table.items.collect {|i| i.attributes.to_h }; end
  def find(hash_value)
    it = @_table.items[hash_value]
    @attributes.clear
    it.attributes.to_h.each {|k, v| self.send("#{k}=".to_sym, v) unless k == @hash_key }
    @hash_value = hash_value; @is_new = false
    @attributes
  end

  def is_new?; @is_new; end
  def save(hash_value = nil)
    raise "missing hash value" if hash_value.nil? and is_new?
    @_item = item = @_table.items.create(@hash_key.to_sym => hash_value) if is_new?
    if @_item
      @_item.attributes.set(@attributes)
      @is_new = false; @hash_value = hash_value
      @_item.attributes.to_h
    end
  end

  def destroy
    unless is_new?
      @_item.delete
      @hash_value = nil; @is_new = true
    end
  end

  def method_missing(method, *args, &block)
    if RESERVED.include?(method.to_s)
      self.send(method.to_sym, *args, &block)
    else
      if method.to_s.include?("=")
        @attributes[method.to_s.gsub("=","")] = args.first
      else
        @attributes[method.to_s]
      end
    end
  end
end
