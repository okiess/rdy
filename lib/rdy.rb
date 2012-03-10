require "rubygems"
gem "aws-sdk"
require "aws-sdk"
require 'digest'

class Rdy
  attr_accessor :hash_key_conditional_check, :check_table_status
  @@_tables = {}
  
  def initialize(table, hash_key, range_key = nil)
    @attributes = {}; @table = table.to_s; @hash_key = hash_key[0].to_s
    @range_key = range_key[0].to_s if range_key
    @is_new = true
    self.hash_key_conditional_check = false
    self.check_table_status = false
    if @@_tables[table]
      @_table = @@_tables[table]
    else
      @_table = Rdy.dynamo_db.tables[@table]
      if self.check_table_status
        if @_table.status == :active
          @@_tables[table] = @_table
        else
          raise "Table not active yet!"
        end
      else
        @_table.hash_key = [@hash_key.to_sym, hash_key[1].to_sym]
        @_table.range_key = [@range_key.to_sym, range_key[1].to_sym] if @range_key
      end
    end
  end
  def table=(value); @table = value.to_s; end
  def table; @table; end
  def table_exists?; @_table.exists?; end
  def attributes; @attributes; end
  def hash_value; @hash_value; end
  def hash_key; @hash_key; end
  def range_key; @range_key; end
  def range_value; @range_value; end
  def range_value=(rv); @range_value = rv; end
  def self.generate_key; Digest::SHA1.hexdigest((0...50).map{ ('a'..'z').to_a[rand(26)] }.join); end
  
  def self.dynamo_db
    config = YAML.load(File.read("#{ENV['HOME']}/.rdy.yml"))
    raise "Config file expected in ~/.rdy.yml" unless config
    @@dynamo_db = AWS::DynamoDB.new(:access_key_id => config['access_key_id'],
                                   :secret_access_key => config['secret_access_key'],
                                   :dynamo_db_endpoint => config['dynamo_db_endpoint'])
  end
  def self.create_table(table, read_capacity_units, write_capacity_units, hash_key, range_key = nil)
    dynamo_db.tables.create(table, read_capacity_units, write_capacity_units,
      :hash_key => hash_key, :range_key => range_key)
  end

  def self.create(table, hash_key_value, range_key_value, attrs = {})
    raise "No attributes given!" unless attrs
    rdy = Rdy.new(table, hash_key_value[0..1], range_key_value ? range_key_value[0..1] : nil)
    rdy.build(attrs.merge(hash_key_value[0].to_sym => hash_key_value[2]))
    if range_key_value
      rdy.send("#{range_key_value[0]}=".to_sym, range_key_value[2])
      rdy.send(:range_value=, range_key_value[2])
    end
    rdy.save(hash_key_value[2])
    rdy
  end

  def build(attrs)
    if attrs
      @attributes.clear
      attrs.each {|k, v| self.send("#{k.to_s}=".to_sym, v) unless k == @hash_key }
      return self
    end
  end

  def all; @_table.items.collect {|i| i.attributes.to_h }; end
  def self.find(table, hash_key_value, range_key_value = nil)
    rdy = Rdy.new(table, hash_key_value[0..1], range_key_value ? range_key_value[0..1] : nil)
    rdy.find(hash_key_value[2], range_key_value ? range_key_value[2] : nil)
    rdy
  end
  def find(hash_value, range_value = nil)
    raise "missing hash value" if hash_value.nil?
    if @range_key and range_value
      @_item = @_table.items.at(hash_value, range_value)
    else
      @_item = @_table.items[hash_value]
    end
    @attributes.clear
    if @_item and @_item.attributes and @_item.attributes.any?
      self.build(@_item.attributes.to_h)
      @hash_value = hash_value; @is_new = false
      @range_value = range_value if range_value
    else
      @hash_value = nil
    end
    @attributes
  end
  def count; @_table.items.count; end

  def is_new?; @is_new; end
  def save(hash_value = nil)
    hash_value = Rdy.generate_key if hash_value.nil? and is_new?
    if is_new?
      options = {}; values = { @hash_key.to_sym => hash_value }
      options[:unless_exists] = @hash_key if hash_key_conditional_check
      @_item = @_table.items.create(values.merge(@attributes), options)
      @hash_value = hash_value
      @is_new = false
    else
      if @range_key
        attrs = @attributes.clone; attrs.delete(@range_key)
        @_item.attributes.set(attrs)
      else
        @_item.attributes.set(@attributes)
      end
    end
    @_item.attributes.to_h if @_item
  end

  def scan(attrs, limit = nil)
    values = []; options = {}
    options[:limit] = limit if limit
    @_table.items.where(attrs).each(options) do |item|
      values << item.attributes.to_h
    end
    values
  end

  def query(options = {})
    if options and options.any?
      values = []
      @_table.items.query(options).each do |item|
        values << item.attributes.to_h
      end
      values
    end
  end
  def query_by_range_value(value); query(:hash_value => self.hash_value.to_s, :range_value => value); end

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

class RdyItem < Rdy
  def initialize(hash_key, range_key = nil, table = nil)
    super(table ? table.to_s : "#{self.class.name.downcase}s", hash_key, range_key)
  end

  def self.create_table(read_capacity_units, write_capacity_units, hash_key, range_key = nil)
    dynamo_db.tables.create(self.table, read_capacity_units, write_capacity_units,
      :hash_key => hash_key, :range_key => range_key)
  end
end
