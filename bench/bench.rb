require 'benchmark'
load '../lib/match_map.rb'
load 'mmopt.rb'
require 'pp'

h5 = {
  'a' => 'A',
  'b' => 'B',
  'c' => 'C',
  'd' => 'D',
  'e' => 'E',
  # /a/ => 'AAA'
}

@mm = MatchMap.new
@mmo = MatchMapOpt.new
h5.each_pair {|k,v| @mm[k] = v; @mmo[k] = v}

@mm2 = MatchMap.new()
@mmo2 = MatchMapOpt.new()
(1..20).each do |i|
  @mm2[i] = i*2
  @mmo2[i] = i * 2
end
# h20[/a/] = 'AAA'


iters = 100_000

Benchmark.bm do |x|

  x.report('hash            ') do
    1..iters.times do
      y = h5['a']
    end
  end

  x.report('straight 5 keys ') do
    1..iters.times do
      y = @mm['a']
    end
  end
  
  x.report('optimized 5 keys') do
    1..iters.times do
      y = @mmo['a']
    end
  end

  x.report('straight 20 keys') do
    1..iters.times do
      y = @mm2['a']
    end
  end
  
  
  x.report('optimized 20 keys') do
     1..iters.times do
       y = @mmo2['a']
     end
   end


end