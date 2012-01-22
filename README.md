# rdy

Fun little ruby client for Amazon DynamoDB.

    rdy = Rdy.new("your_table", "your_hash_value")
    rdy.any_attribute = "nice!"
    rdy.foo = "bar"
    rdy.save("1")
    
    rdy.foo = "bar2"
    rdy.save
    
    rdy.any_attribute = nil
    rdy.save
    
    rdy.find("1")
    rdy.destroy

    rdy.all
    
Advanced features like queries, scans etc. are not supported yet.

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
