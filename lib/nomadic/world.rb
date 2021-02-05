module Nomadic
  class Void
    class Point
      include Redis::Objects
      sorted_set :stat
      hash_key :attr
      set :link
      set :here
      def initialize i
        @id = i
      end
      def id; @id; end
    end
    def initialize u
      @user = u
      @here = "void"
    end
    def [] p
      pp = Point.new(p)
      Point.new(@here).here.delete(@user)
      pp.here << @user
      @here = p
      pp
    end
    def link h, *l
      l.each {|e| Point.new(e).link << h; Point.new(h) << e; }
    end
    
  end
  def self.void u
    Void.new(u)
  end
end
@void = Nomadic.void("my")
