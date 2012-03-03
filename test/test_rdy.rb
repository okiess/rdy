require 'helper'

class TestRdy < Test::Unit::TestCase
  def rdy
    @rdy = Rdy.new(RDY_SIMPLE_TABLE, [:id, :string])
  end

  def rdy_range
    @rdy2 = Rdy.new(RDY_RANGE_TABLE, [:id, :string], [:foo, :string])
  end

  should "create an Rdy instance" do
    assert_equal rdy.table, RDY_SIMPLE_TABLE
    assert_equal rdy.hash_key, 'id'
    assert_nil rdy.hash_value, nil
  end
  
  should "create an Rdy instance for table with a range key" do
    assert_equal rdy_range.table, RDY_RANGE_TABLE
    assert_equal rdy_range.hash_key, 'id'
    assert_equal rdy_range.range_key, 'foo'
    assert_nil rdy.hash_value, nil
  end
  
  context "Attributes" do
    setup do
      rdy
    end
  
    should "create assign a value to an attribute" do
      @rdy.foo = "bar"
      @rdy.bar = 23
      @rdy.tags = ['a', 'b', 'c']
      assert_equal @rdy.foo, "bar"
      assert_equal @rdy.bar, 23
      assert_not_nil @rdy.tags
      assert_equal @rdy.tags.size, 3
    end
    
    should "have values in attributes hash" do
      assert @rdy.attributes.empty?
      @rdy.foo = "bar"
      assert_equal @rdy.foo, "bar"
      assert_equal @rdy.attributes.size, 1
      assert_equal @rdy.attributes['foo'], 'bar'
    end
    
    should "build an Rdy instance from an attributes hash" do
      rdy
      attributes = { 'test' => 'testval', 'foo' => 'bar', :number => 1}
      rdy_instance = Rdy.new(RDY_SIMPLE_TABLE, [:id, :string]).build(attributes)
      assert_not_nil rdy_instance
      assert_equal rdy_instance.test, 'testval'
      assert_equal rdy_instance.foo, 'bar'
      assert_equal rdy_instance.number, 1
    end
  end

  context "Creating" do
    setup do
      rdy
    end
    
    should "save an item" do
      assert @rdy.is_new?
      @rdy.foo = "bar"
      @rdy.count = 1
      @rdy.tags = ['a', 'b', 'c']
      assert_equal @rdy.foo, "bar"
      assert_equal @rdy.table, RDY_SIMPLE_TABLE
      assert_nil @rdy.hash_value
      hash_value = Rdy.generate_key
      attributes = @rdy.save(hash_value)
      assert_equal @rdy.hash_value, hash_value
      assert_equal attributes.size, 4
      assert attributes.keys.include?('id')
      assert attributes.keys.include?('foo')
      assert attributes.keys.include?('count')
      assert attributes.keys.include?('tags')
      assert !@rdy.is_new?
      @rdy.destroy
    end
  end
  
  context "Updating" do
    setup do
      rdy
    end

    should "update an item" do
      @rdy.foo = "bar"
      hash_value = Rdy.generate_key
      attributes = @rdy.save(hash_value)
      assert !@rdy.is_new?
      assert_equal @rdy.hash_value, hash_value
      assert_equal @rdy.foo, "bar"
      assert_equal attributes['foo'], "bar"
      @rdy.foo = "bar2"
      attributes = @rdy.save
      assert !@rdy.is_new?
      assert_equal @rdy.hash_value, hash_value
      assert_equal @rdy.foo, "bar2"
      assert_equal attributes['foo'], "bar2"
      @rdy.destroy
    end
  end

  context "Destroying" do
    setup do
      rdy
    end
    
    should "destroy an item" do
      @rdy.foo = "bar"
      hash_value = Rdy.generate_key
      attributes = @rdy.save(hash_value)
      @rdy.find(hash_value)
      assert_not_nil @rdy.foo
      assert_equal @rdy.foo, "bar"
      @rdy.destroy
      @rdy.find(hash_value)
      assert_nil @rdy.hash_value
    end
  end
  
  context "Scan Table" do
    setup do
      rdy_range
    end
    
    should "scan table by attribute values" do
      hash_value1 = Rdy.generate_key
      @rdy2 = Rdy.new(RDY_RANGE_TABLE, [:id, :string], [:foo, :string])
      @rdy2.foo = "bar1"
      @rdy2.data = "test"
      @rdy2.save(hash_value1)
      
      hash_value2 = Rdy.generate_key
      @rdy3 = Rdy.new(RDY_RANGE_TABLE, [:id, :string], [:foo, :string])
      @rdy3.foo = "bar2"
      @rdy3.data = "test"
      @rdy3.save(hash_value2)

      attrs = @rdy2.scan(:data => 'test')
      assert_not_nil attrs
      assert_equal attrs.size, 2

      attrs = @rdy2.scan(:data => 'test', :foo => 'bar1')
      assert_not_nil attrs
      assert_equal attrs.size, 1
      assert_equal attrs[0]['foo'], 'bar1'

      attrs = @rdy2.scan(:data => 'test', :foo => 'bar2')
      assert_not_nil attrs
      assert_equal attrs.size, 1
      assert_equal attrs[0]['foo'], 'bar2'

      limit = 1
      attrs = @rdy2.scan({:data => 'test'}, limit)
      assert_not_nil attrs
      assert_equal attrs.size, 1
      
      @rdy2.find(hash_value1, "bar1")
      @rdy2.destroy
      
      @rdy3.find(hash_value2, "bar2")
      @rdy3.destroy
    end
  end

  context "Finding hash-key based items" do
    setup do
      rdy
    end
    
    should "find an item by hash-key" do
      hash_value = Rdy.generate_key
      @rdy.foo = "bar"
      attributes = @rdy.save(hash_value)
      @rdy.find(hash_value)
      assert_not_nil @rdy.foo
      assert_equal @rdy.foo, "bar"
      @rdy.destroy
    end
    
    should "use the find class method" do
      hash_value = Rdy.generate_key
      @rdy.foo = "bar"
      attributes = @rdy.save(hash_value)
      rdy_result = Rdy.find(RDY_SIMPLE_TABLE, [:id, :string, hash_value])
      assert_not_nil rdy_result
      assert rdy_result.is_a?(Rdy)
      assert_not_nil rdy_result.attributes
      assert_equal rdy_result.foo, 'bar'
      assert_equal rdy_result.hash_value, hash_value
      @rdy.destroy
    end
  end

  context "Finding hash-key/range based items" do
    setup do
      rdy_range
    end
    
    should "find an item by hash-key & range combination" do
      hash_value = Rdy.generate_key
      @rdy2.foo = "bar"
      attributes = @rdy2.save(hash_value)
      @rdy2.find(hash_value, "bar")
      assert_not_nil @rdy2.foo
      assert_equal @rdy2.foo, "bar"
      @rdy2.destroy
    end
    
    should "use the find class method" do
      hash_value = Rdy.generate_key
      @rdy2.foo = "bar"
      attributes = @rdy2.save(hash_value)
      rdy_result = Rdy.find(RDY_RANGE_TABLE, [:id, :string, hash_value], [:foo, :string, 'bar'])
      assert_not_nil rdy_result
      assert rdy_result.is_a?(Rdy)
      assert_not_nil rdy_result.attributes
      assert_equal rdy_result.foo, 'bar'
      assert_equal rdy_result.hash_value, hash_value
      assert_equal rdy_result.range_value, 'bar'
      @rdy2.destroy
    end
  end
  
  context "Query Table" do
    setup do
      rdy_range
    end
    
    should "query table by hash value and range value" do    
      hash_value1 = Rdy.generate_key
      @rdy2 = Rdy.new(RDY_RANGE_TABLE, [:id, :string], [:foo, :string])
      @rdy2.foo = "a"
      @rdy2.save(hash_value1)
      
      hash_value2 = Rdy.generate_key
      @rdy3 = Rdy.new(RDY_RANGE_TABLE, [:id, :string], [:foo, :string])
      @rdy3.foo = "b"
      @rdy3.save(hash_value2)

      attrs = @rdy2.query(:hash_value => hash_value1, :range_value => "a")
      assert_not_nil attrs
      assert_equal attrs.size, 1
      assert_equal attrs[0]['id'], hash_value1
      assert_equal attrs[0]['foo'], 'a'
      
      attrs = @rdy2.query_by_range_value("a")
      assert_not_nil attrs
      assert_equal attrs.size, 1
      assert_equal attrs[0]['id'], hash_value1
      assert_equal attrs[0]['foo'], 'a'
      
      attrs = @rdy2.query_by_range_value("b")
      assert_not_nil attrs
      assert_equal attrs.size, 0
      
      attrs = @rdy3.query(:hash_value => hash_value2, :range_value => "b")
      assert_not_nil attrs
      assert_equal attrs.size, 1
      assert_equal attrs[0]['id'], hash_value2
      assert_equal attrs[0]['foo'], 'b'
      
      attrs = @rdy3.query_by_range_value("b")
      assert_not_nil attrs
      assert_equal attrs.size, 1
      assert_equal attrs[0]['id'], hash_value2
      assert_equal attrs[0]['foo'], 'b'
      
      attrs = @rdy3.query_by_range_value("a")
      assert_not_nil attrs
      assert_equal attrs.size, 0

      @rdy2.find(hash_value1, "a")
      @rdy2.destroy
      
      @rdy3.find(hash_value2, "b")
      @rdy3.destroy
    end
  end
end
