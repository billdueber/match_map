class MatchMap < Hash
  attr_accessor :pchecks
  attr_reader :echo
  
  def initialize echo = nil
    super [] # set default value as []
    @dirty = true
    @pchecks = 0
    @echo = echo
  end

  def echo= arg
    raise RuntimeError.new, "echo value must be :onmiss or :always" unless [:onmiss, :always].include? arg
    @echo = arg
  end

  def []= key, val
    unless key.is_a? Regexp
      key = Regexp.new('^' + Regexp.escape(key.to_s) + '$')
    end
    super
    @dirty = true
  end
  
  alias_method :old_get, :[]
  
  def [] arg
    rv = []
    rv.push *arg if @echo == :always
    if arg.is_a? Array
      arg.map {|s| inner = self.inner_get(s); rv.push *inner}
      rv.uniq!
      rv.compact!
    else
      inner = self.inner_get arg
      rv.push *inner
    end
    return rv
  end
    
  
  def inner_get arg
    arg = arg.to_s
    rv = []
    unless @dirty
      @pchecks += 1
      return self.default unless @super_regexp.match arg
    end
    rv = []
    self.each_pair do |k,v|
      m = k.match arg
      if m
        if v.is_a? Proc
          processed = v.call m
          rv.push *processed
        else
          rv.push *v
        end
      end
      @pchecks += 1
    end
    rv.uniq!
    rv.compact!
    if rv.size == 0
      rv.push arg if @echo == :onmiss
    end
    return rv
  end
  
  
  # Do what we can to reduce the number of regexp calls
  # It turns out they're expensive, so if you're going to
  # be using a map a few times, it's worth the effort.
  # 
  def optimize
    return unless @dirty
    # Make a super-regexp that matches everything
    @super_regexp = Regexp.union self.keys
    
    # Build an inverted set for cases where a single value or set of
    # values map to multiple patterns
    #
    # First, build up the inverted map
    inverted = {}
    self.each_pair do |p,v|
      inverted[v] ||= []
      inverted[v] << p
    end
    # Now, find places where values are repeated and just build
    # a single larger regexp for it. e.g., if 
    # /a/ => 1 and /b/ => 1, then replace them both with
    # /a|b/ => 1. 
    inverted.each_pair do |vals, patterns|
      next unless patterns.size > 1
      newpat = Regexp.union patterns
      if self.has_key? newpat
        vals += self.old_get newpat
        vals.uniq!
      end
      patterns.each do |p|
        self.delete p
      end
      self[newpat] = vals
    end
    
    @dirty = false
  end
end