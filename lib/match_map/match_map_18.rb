require 'hashery/ordered_hash'

module MatchMapIncludes
  module OnePointEight
    # 1.8 setup
    def setup h
      singleton_class = class << self; self; end
      singleton_class.send(:define_method, :inner_get, method(:normal_inner_get))
      @map = OrderedHash.new
      h.each_pair do |k, v| 
        @map[k] = v
        set_attrs k, v
      end  
    end
  end
end