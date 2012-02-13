require 'helper'

class TestRdy < Test::Unit::TestCase
  def rdy
    @rdy = Rdy.new('rdy_test', 'id')
  end
  
  should "create an Rdy instance" do
    rdy = Rdy.new('rdy_test', 'id')
    assert_equal rdy.table, 'rdy_test'
    assert_equal rdy.hash_key, 'id'
    assert_nil rdy.hash_value, nil
  end
  
  context "Attributes" do
    setup do
      rdy
    end
  
    should "create assign a value to an attribute" do
      @rdy.foo = "bar"
      @rdy.bar = 23
      @rdy.flag = true
      assert_equal @rdy.foo, "bar"
      assert_equal @rdy.bar, 23
      assert @rdy.flag
    end
    
    should "have values in attributes hash" do
      assert @rdy.attributes.empty?
      @rdy.foo = "bar"
      assert_equal @rdy.foo, "bar"
      assert_equal @rdy.attributes.size, 1
      assert_equal @rdy.attributes['foo'], 'bar'
    end
  end
  
  context "Creating" do
    setup do
      rdy
    end
    
    should "save an item" do
      assert @rdy.is_new?
      @rdy.foo = "bar"
      assert_equal @rdy.foo, "bar"
      assert_equal @rdy.table, "rdy_test"
      assert_nil @rdy.hash_value
      attributes = @rdy.save('1')
      assert_equal @rdy.hash_value, '1'
      assert_equal attributes.size, 2
      assert attributes.keys.include?('id')
      assert attributes.keys.include?('foo')
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
      attributes = @rdy.save("2")
      assert !@rdy.is_new?
      assert_equal @rdy.hash_value, "2"
      assert_equal @rdy.foo, "bar"
      assert_equal attributes['foo'], "bar"
      @rdy.foo = "bar2"
      attributes = @rdy.save
      assert !@rdy.is_new?
      assert_equal @rdy.hash_value, "2"
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
      attributes = @rdy.save("3")
      @rdy.find("3")
      assert_not_nil @rdy.foo
      assert_equal @rdy.foo, "bar"
      @rdy.destroy
      @rdy.find("3")
      assert_nil @rdy.hash_value
    end
  end
end
