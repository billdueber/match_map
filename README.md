# MatchMap -- a multimap where key matching is based on regular expressions

```ruby
require 'match_map'

mm = MatchMap.new
mm['a'] = 'string'
mm[/a/] = 'apat'
mm[/b/] = ['bpat1', 'bpat2']
mm[/.+b/] = 'bpat3'

mm['a'] #=> ['string', 'apat'] # order *not* guaranteed
mm['aa']  #=> ['apat']
mm['b']   #=> ['bpat1', 'bpat2']
mm['cob']  #=> ['bpat1', 'bpat2', 'bpat3'] # flattened one level!!!
mm['cab']  #=> ['apat', 'bpat1', 'bpat2', 'bpat3']
mm['c']    #=> [] # no match

# You can also query on multiple values at once by passing an array
mm[['a', 'aa', 'b']] #=> ['apat', 'string', 'bpat1', 'bpat2']

# Or use a Proc as the value; it gets the match variable as its argument

mm[/a(b+)/] = Proc.new {|m| [m[1].size]}
mm['abbbb'] #=> [4]


# In many cases, you can optimize the map and it'll get faster (see below)
mm.optimize  # hopefully speed up access
mm['cab']  #=> ['apat', 'bpat1', 'bpat2', 'bpat3'] # same as before

# You can set #echo to always return the argument in addition to other values
mm = MatchMap.new
mm[/ab/] = "AB"

# first, without echo
mm['miss'] = []
mm['cab']  = ['AB']

#...then with echo = :always
mm.echo = :always
mm['miss'] = ['miss']
mm['cab']  = ['cab', 'AB']

#...and again with echo = :onmiss
mm.echo = :onmiss
mm['miss'] #=> ['miss'] # because nothing else matched
mm['cab']  #=> ['AB']   # because a match was found
```

A MatchMap is a hash-like with the following properties:

* keys can be strings or regular expressions
* keys cannot be repeated
* arguments are compared to keys based on #=== (exact match for string, pattern match for patters)
* values can be scalars, arrays (treated as multiple values), or Proc objects
* a scalar argument to #[] is always treated as a string
* an array argument to #[] is treated as if you want all values for all matches for all array members
* a call to #[] always returns an array of values ([] on fail)
* the return value from #[] goes through #uniq and #compact (no repeated values, no nil values)

The idea is that you can set up a bunch of (possibly overlapping) patterns, each of which is associated 
with one or more values, and easily get back all the values for those patterns that match the argument. 

## Using Proc objects as values

You can also use a Proc object as a value. It must:

* take a single argument; the match variable
* return a (possibly empty) array of values

```ruby
mm = MatchMap.new
mm[/^(.+),\s*(.+)$/] = Proc.new {|m| "#{m[2]} #{m[1]}"}
mm['Dueber, Bill'] #=> ["Bill Dueber"]
```    


## Using echo to always/sometimes get back the argument

There are two common requirements when doing this sort of translation for indexing:

* The raw argument should always appear in the ouput
* The raw argument should appear in the output only if there are no other matches. 

```ruby
mm = MatchMap.new
mm[/ab/] = "AB"

# first, without echo
mm['miss'] = []
mm['cab']  = ['AB']

#...then with echo = :always
mm.echo = :always
mm['miss'] = ['miss']
mm['cab']  = ['cab', 'AB']

#...and again with echo = :onmiss
mm.echo = :onmiss
mm['miss'] #=> ['miss'] # because nothing else matched
mm['cab']  #=> ['AB']   # because a match was found
```

## Optimizing

A call to #optimize will speed up access by reducing the number of regular expression checks, assuming the following are true:

* A significant number of accesses result in misses, and/or
* Some of your keys return the same value(s).

If neither of these things are true, you will end up doing *more* pattern checks, so calling it #optimize might be a tad...er...optimistic. 

## Gotchas

* order of values returned is not guaranteed! 
* Return value is always an array, possibly empty. So no `if mm['val']...`
* Return values are flattened one level. So, a => 1 and b => [2,3], the something that matches both will return [1,2,3]. If you really want to return an array, you need to do something like a => [[1,2]]
  

## Contributing to MatchMap
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 Bill Dueber. See LICENSE.txt for
further details.
