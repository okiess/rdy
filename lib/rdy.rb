require "rubygems"
gem "aws-sdk"
require "aws-sdk"

class Rdy
  @@_tables = {}
  def initialize(table, hash_key, range_key = nil)
    @attributes = {}; @table = table; @hash_key = hash_key; @range_key = range_key
    @is_new = true
    if @@_tables[table]
      @_table = @@_tables[table]
    else
      @_table = Rdy.dynamo_db.tables[@table]
      if @_table.status == :active
        @@_tables[table] = @_table
      else
        raise "Table not active yet!"
      end
    end
  end
  def table=(value); @table = value; end
  def table; @table; end
  def attributes; @attributes; end
  def hash_value; @hash_value; end
  def hash_key; @hash_key; end
  def range_key; @range_key; end

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
    raise "missing hash value" if hash_value.nil?
    @_item = @_table.items[hash_value]
    @attributes.clear
    if @_item.attributes.any?
      @_item.attributes.to_h.each {|k, v| self.send("#{k}=".to_sym, v) unless k == @hash_key }
      @hash_value = hash_value; @is_new = false
    else
      @hash_value = nil
    end
    @attributes
  end
  def count; @_table.items.count; end

  def is_new?; @is_new; end
  def save(hash_value = nil)
    raise "missing hash value" if hash_value.nil? and is_new?
    if is_new?
      @_item = @_table.items.create(@range_key ? { @hash_key.to_sym => hash_value, @range_key.to_sym => @attributes[@range_key] } : { @hash_key.to_sym => hash_value })
    end
    if @_item
      if @range_key
        attrs = @attributes; attrs.delete(@range_key)
        @_item.attributes.set(attrs)
      else
        @_item.attributes.set(@attributes)
      end
      @hash_value = hash_value if is_new?
      @is_new = false
      @_item.attributes.to_h
    end
  end

  def destroy
    unless is_new?
      @_item.delete
      @hash_value = nil; @_item = nil; @is_new = true
    end
  end

  private
  def method_missing(method, *args, &block)
    if method.to_s[-1, 1] == '='
      @attributes[method.to_s.gsub('=', '')] = args.first
    else
      @attributes[method.to_s]
    end
  end
end
