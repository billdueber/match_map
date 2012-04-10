module MatchMapIncludes
  module OnePointNine
    
    # 1.9 setup
    def setup h
      @map = {}
      h.each_pair do |k, v| 
        @map[k] = v
        set_attrs k, v
      end  
      define_singleton_method :inner_get, method(:normal_inner_get)
    end
  end
end