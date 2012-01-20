# A hash-like object that tries to match an argument against
# *all* keys (using == for non-Regexp keys and pattern matching
# for Regexp keys)

class MatchMap

  attr_accessor :default
  attr_reader   :echo

  def initialize echo = nil
    @default = nil # default miss value is nil
    @echo = echo
    @keys = []
    @map = {}
  end

  def echo= arg
    raise RuntimeError.new, "echo value must be :onmiss or :always" unless [:onmiss, :always].include? arg
    @echo = arg
  end

  def []= key, val
    @map[key] = val
    @keys.push key unless @keys.include? key
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


  def inner_get arg
    rv = []
    @keys.each do |k|
      if k.is_a? Regexp
        m = k.match arg.to_s
      else
        m = (k == arg) ? arg : false
      end
      if m
        v = @map[k]
        if v.is_a? Proc
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

end