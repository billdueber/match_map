require 'benchmark'
load '../lib/match_map.rb'


a = 1
b = {a=>{:regexp => true}}

Benchmark.bm do |x|
  x.report('isa ') do 
    2_000_000.times do 
      y = a.is_a? Regexp
    end
  end
  
  x.report('hash') do 
    2_000_000.times do 
      y = b[a][:regexp]
    end
  end 
end