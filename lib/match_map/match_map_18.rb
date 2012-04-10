# In ruby 1.8x, the Hashes are not ordered, so we fall back on 
# the hashery ordered_hash

require 'hashery/ordered_hash'

module MatchMapIncludes
  module OnePointEight
    # 1.8 setup
    def setup h
      singleton_class = class << self; self; end
      singleton_class.send(:define_method, :inner_get, method(:normal_inner_get))
      @map = OrderedHash.new
    end
  end
end