# The 1.9 hash is already ordered; just use it

module MatchMapIncludes
  module OnePointNine
    
    # 1.9 setup
    def setup h
      @map = {}
      define_singleton_method :inner_get, method(:normal_inner_get)
    end
  end
end