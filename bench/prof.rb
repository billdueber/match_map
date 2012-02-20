load '../lib/match_map.rb'


@mm = MatchMap.new
(1..20).each do |i|
  @mm[i] = i*2
end
@mm[/a/] = 'AAA'

y = nil
10000.times {y = @mm['a']}
puts "Y is #{y}"