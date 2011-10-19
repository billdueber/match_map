require 'helper'

describe MatchMap do

  before do
    @h = MatchMap.new
  end
   
  describe "when empty" do
        
    it "should return nil (default)" do
      @h['a'].must_equal nil
    end
    
    it 'should allow set of default' do
      @h.default = 'def'
      @h['a'].must_equal 'def'
    end
    
  end
  
  describe "when a single string key" do
    it 'should set correctly' do
      @h['a'] = 3
      @h['a'].must_equal [3]
    end
        
    it 'should still return default' do
      @h['a'] = 3
      @h['c'].must_equal @h.default
    end
    
    it 'should reset a value' do
      @h['a'] = 3
      @h['a'] = 4
      @h['a'].must_equal [4]
    end
    
    it 'should allow array values' do
      @h['a'] = [1,2]
      @h['a'].must_equal [1,2]
    end
    
  end

  
  describe "works with pattern keys" do
    
    it 'works with an always-match pattern' do
      @h[/.?/] = 100
      @h['a']  = 1
      @h[10].must_equal [100]
      @h['a'].must_equal [100, 1]
    end
    
    
    it "uses a single pattern" do
      @h[/.+a/] = 1
      @h['b'].must_equal @h.default
      @h['a'].must_equal @h.default
      @h['aa'].must_equal [1]
      @h['era'].must_equal [1]
    end
    
    it "works with disjoint patterns" do
      @h[/.+a/] = 1
      @h[/b/] = 2
      @h['aa'].must_equal [1]
      @h['ab'].must_equal [2]
      @h['cab'].must_equal [1,2]
    end
  end
  
  describe "works with non-pattern keys" do
        
    it "is fine with strings" do
      @h['a'] = 1
      @h[/a/] = 2
      @h['a'].must_equal [1,2]
      @h['aa'].must_equal [2]
    end
    
    it 'is fine with fixnums' do
      @h[1] = 1
      @h[2] = 2
      @h[12] = 3
      @h[1].must_equal [1]
      @h[2].must_equal [2]
      @h[12].must_equal [3] 
    end
  end

  describe "works with a Proc" do
    it 'does an echo proc' do
      @h[/ab+/] = Proc.new {|m| m[0]}
      @h['ab'].must_equal ['ab']
    end
    
    it 'deals with match data' do
      @h[/a(b+)/] = Proc.new {|m| [m[0], m[1].size.to_s]}
      @h[/abb/].must_equal ['abb', '2']
    end
    
    it "works with a more complex proc" do
      mm = MatchMap.new
      mm[/^(.+),\s*(.+)$/] = Proc.new {|m| "#{m[2]} #{m[1]}"}
      mm['Dueber, Bill'].must_equal ["Bill Dueber"]
    end
    
    it "calls the Proc for string argument, even though that kind of an abuse" do
      mm = MatchMap.new
      mm['a'] = Proc.new {|m| [m[0] + 'bbb']}
      mm['a'].must_equal ['abbb']
    end
  end
  
  describe "works with echo" do
    before do
      @j  = MatchMap.new
    end
    
    it "echos when empty" do
      @j['miss'].must_equal @h.default # no echoing
      
      @j.echo = :always
      @j['miss'].must_equal ['miss']
      
      @j.echo = :onmiss
      @j['miss'].must_equal ['miss']
    end
    
    it "echos when not empty" do
      @j[/a/] = 'hello'
      
      @j['miss'].must_equal @j.default
      
      @j.echo = :always
      @j['miss'].must_equal ['miss']
      @j['ab'].must_equal ['ab', 'hello'].sort
      
      @j.echo = :onmiss
      @j['miss'].must_equal ['miss']
      @j['ab'].must_equal ['hello']
      
    end
    
    it "works with a Proc and echo" do
      mm = MatchMap.new
      mm[/^(.+),\s*(.+)$/] = Proc.new {|m| "#{m[2]} #{m[1]}"}
      mm.echo = :always
      mm['Dueber, Bill'].must_equal ['Dueber, Bill', "Bill Dueber"]
    end
    
  end
  
  describe 'Multiple key arguments' do
    before do
      @h = MatchMap.new
      @h['a'] = 1
      @h['b'] = 2
      @h[/c/] = 3
    end
    
    it 'works with simple array arg' do
      @h[['a', 'b']].must_equal [1,2]
    end
    
    it "works with echo" do
      @h.echo = :always
      @h[['a', 'ac']].must_equal ['a', 'ac', 1, 3]
    end
    
    it 'misses hard' do
      @h[[1,2,3]].must_equal nil
    end
    
  end
      
    
      
  
  # describe 'works when optimizing' do
  #   before do
  #     @h[/a/] = 1
  #     @h[/b/] = 2
  #     @h[/c/] = 1
  #     @h[/d/] = 2
  #     @h.optimize
  #   end
  #   
  #   it "should still get correct results" do
  #     @h[3].must_equal []
  #     @h['aa'].must_equal [1]
  #     @h['ca'].must_equal [1]
  #     @h['cab'].must_equal [1,2]
  #   end
  #   
  # end
  
  # describe "does correct number of checks when optimizing" do
  #   before do
  #     @h[/a/] = 1
  #     @h[/b/] = 2
  #     @h[/c/] = 1
  #     @h[/d/] = 2
  #     @h.optimize
  #   end
  #   
  #   it "does a single check on miss" do
  #     @h['1']
  #     @h.pchecks.must_equal 1
  #   end
  #   
  #   it "should optimize away common values" do
  #     @h.size.must_equal 2
  #   end
  #   
  #   it "reduced number of checks" do
  #     @h['abcd']
  #     @h.pchecks.must_equal 3 
  #   end
  #   
  # end
end