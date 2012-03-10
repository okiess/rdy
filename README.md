# rdy

Fun little ruby client for Amazon DynamoDB.

    # hash-key based tables
    rdy = Rdy.new("your_table", [:your_hash_key, :string])
    rdy.any_attribute = "nice!"
    rdy.foo = "bar"
    rdy.save("1") # set your hash key value
    # rdy.save # if ommitted the hash key value is generated

    rdy.foo = "bar2"
    rdy.save # update
    
    rdy.any_attribute = nil
    rdy.save # delete an attribute
    
    rdy.find("1") # find by hash key value / sets values to current instance
    rdy_instance = Rdy.find("your_table", [:your_hash_key, :string, 'mykey1']) # returns new Rdy instance

    rdy.destroy # delete item

    rdy_instance = Rdy.create('your_table', [:your_hash_key, :string, "your_hash_key"], nil, {"foo" => "bar"})

    rdy.all
    rdy.count

    rdy.scan(:any_attribute => 'nice!')
    limit = 10
    rdy.scan(:any_attribute => 'nice!', limit)

    # hash & range-key based tables
    rdy2 = Rdy.new("your_table", [:your_hash_key, :string], [:your_range_key, :number])
    rdy2.your_range_key = 1
    rdy2.save('mykey1') # or just rdy2.save

    rdy_instance = Rdy.create('your_table', [:your_hash_key, :string, "your_hash_value"], [:your_range_key, :number, 1], {"foo" => "bar"})

    rdy2.find('mykey1', 1) # sets item values to current instance
    rdy_instance = Rdy.find("your_table", [:your_hash_key, :string, 'mykey1'], [:your_range_key, :number, 1]) # returns new Rdy instance

    rdy2.query(:hash_value => 'mykey1', :range_value => 1)
    rdy2.query_by_range_value(1)

    read_capacity_units = 10
    write_capacity_units = 5
    Rdy.create_table("rdy", read_capacity_units, write_capacity_units, :id => :string) # hash key only
    Rdy.create_table("rdy2", read_capacity_units, write_capacity_units, {:id => :string}, {:comment_id => :number}) # hash and range key

    # You can also create your own class
    class User < RdyItem
        def initialize(hash_key, range_key) # this will save data to the 'users' table
            super(hash_key, range_key)
        end
    end

    user = User.new([:your_hash_key, :string], [:your_range_key, :number])
    
## Installation

    gem install rdy
    
Create a .rdy.yml file with your AWS credentials in your home directory. Checkout the sample file for help. Also make sure you activate DynamoDB in your AWS account.

## Tests

    rake test
    
On the initial run the tables are created. This may take a while, so it's possible the first run of the tests is going to fail. You can also create the tables manually if you want to avoid this. Check out the helper.rb class.

## Contributing to rdy
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Oliver Kiessler. See LICENSE.txt for
further details.
