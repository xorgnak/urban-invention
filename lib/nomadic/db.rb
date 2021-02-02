module Nomadic
  def db
    DB.new
  end
  def self.db
    DB.new
  end
  class DB
    def initialize
      @redis = Redis.new(host: "localhost", port: 6379, db: 0)
      @types = Redis::HashKey.new("nomadic:types")
    end
    def get k
      case @types[k.to_s]
      when "Array"
        Redis::List.new(k.to_s).values
      when "Hash"
        Redis::HashKey.new(k.to_s).all
      when "Set"
        { members: Redis::Set.new(k.to_s).members,
         sorted: Redis::SortedSet.new("sorted:" + k.to_s).members(with_scores: true).to_h }
      else
        Redis::Value.new(k.to_s).value
      end
    end
    def [] k
      get(k)
    end
    def []= k,v
      set k,v
    end
    def sets *i
      @a_s = Redis::SortedSet.new("sorted:" + i[0].to_s).members(with_scores: true).to_h
      @b_s = Redis::SortedSet.new("sorted:" + i[2].to_s).members(with_scores: true).to_h
      @a_m = Redis::Set.new(i[0].to_s)
      @b_m = Redis::Set.new(i[2].to_s)
      
      @h = {}
      case i[1]
      when '&'
        @s = @a_m & @b_m
      when '^'
        @s = @a_m - @b_m
      when '|'
        @s = @a_m | @b_m
      end
      @s.each { |e| @h[e] = { i[0] => @a_s[e], i[2] => @b_s[e] } }
      return @h
    end
    def rm k
      Redis.new.del(k.to_s)
    end
    def set k, v
      @types[k.to_s] = v.class
      case @types[k.to_s]
      when "Array"
        v.each { |e| Redis::List.new(k.to_s) << e.to_s }
      when "Hash"
        v.each_pair {|kk,vv| Redis::HashKey.new(k.to_s)[kk.to_s] = vv.to_s }
      when "Set"
        v.each { |e|
          Redis::SortedSet.new("sorted:" + k.to_s).incr(e.to_s);
          Redis::Set.new(k.to_s) << e
        }
      else
        Redis::Value.new(k.to_s).value = v.to_s
      end
      get(k)
    end
  end
end
@db = Nomadic.db
