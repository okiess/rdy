# rdy

Fun little ruby client for Amazon DynamoDB.

    rdy = Rdy.new("your_table", "your_hash_value")
    rdy.any_attribute = "nice!"
    rdy.foo = "bar"
    rdy.save("1") # hash key value
    
    rdy.foo = "bar2"
    rdy.save # update
    
    rdy.any_attribute = nil
    rdy.save # delete an attribute
    
    rdy.find("1") # find by hash key value
    rdy.destroy # delete item

    rdy.all

    read_capacity_units = 10
    write_capacity_units = 5
    Rdy.create_table("rdy", read_capacity_units, write_capacity_units, :id => :string) # hash key only
    Rdy.create_table("rdy2", read_capacity_units, write_capacity_units, {:id => :string}, {:comment_id => :number}) # hash and range key
    
Advanced features like queries, scans etc. are not supported yet.

## Installation

    gem install rdy
    
Then create a .rdy.yml file with your AWS credentials in your home directory. Checkout the sample file for help. Also make sure you activate DynamoDB in your AWS account.

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
