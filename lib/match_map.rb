# A hash-like object that tries to match an argument against
# *all* keys (using == for non-Regexp keys and pattern matching
# for Regexp keys)

class MatchMap

  attr_accessor :default, :checks
  attr_reader   :echo


  def echo= arg
    raise RuntimeError.new, "echo value must be :onmiss or :always" unless [:onmiss, :always].include? arg
    @echo = arg
  end

  def []= key, val
    @map[key] = val
    @keys.push key unless @keys.include? key
    set_attrs key, val
  end
  
  def set_attrs key, val
    @attrs[key] = {:regexkey => (key.is_a? Regexp), :procval => (val.is_a? Proc)}
  end

  def [] arg
    rv = []
    rv.push *arg if @echo == :always
    if arg.is_a? Array
      arg.map {|s| inner = self.inner_get(s); rv.push *inner}
    else
      inner = self.inner_get arg
      rv.push *inner
    end
    rv.uniq!
    rv.compact!
    if rv.size == 0
      if @echo == :onmiss
        return [*arg]
      else
        return @default
      end
    end
    return rv
  end

  def optimized_inner_get arg
    @checks['optimized'] += 1
    return [@map[arg]]
  end

  def normal_inner_get arg
    rv = []
    @keys.each do |k|
      @checks['normal'] += 1
      if @attrs[k][:regexkey]
        m = k.match arg.to_s
      else
        m = (k == arg) ? arg : false
      end
      if m
        v = @map[k]
        if @attrs[k][:procval]
          processed = v.call(m)
          rv.push *processed if processed
        else
          rv.push *v
        end
      end
    end
    return rv
  end

  def has_key? key
    @map.has_key? key
  end

  def delete key
    @map.delete(key)
    @keys.delete(key)
  end

  def initialize hash = {}
    @default = nil # default miss value is nil
    @echo = echo
    @keys = hash.keys
    @map = hash
    @attrs = {}
    @map.each_pair {|k, v| set_attrs k, v}
    @checks = {'normal' => 0, 'optimized' => 0}
    define_singleton_method :inner_get, method(:normal_inner_get)
  end

  def optimize
    @map.each_pair do |k,v|
      if k.is_a? Regexp or v.is_a? Proc
        define_singleton_method :inner_get, method(:normal_inner_get)
        return
      end
    end
    define_singleton_method :inner_get, method(:optimized_inner_get)
  end

end