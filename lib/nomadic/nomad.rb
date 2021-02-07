module Nomadic
  def self.methods
    self.instance_methods
  end
  def self.run r; lambda { `#{r}` }.call; end
  def self.tool t
    @tools = {
      irc: 'emacs -nw --funcall erc',
      org: 'emacs -nw index.org'
    }
    if Redis::HashKey.new("TOOLS").has_key? t.to_s
      self.run Redis::HashKey.new("TOOLS")[t.to_s]
    elsif @tools.has_key? t.to_sym
      self.run @tools[t.to_sym]
    else
      self.run t.to_s
    end
  end
  
  def self.help
#    he = []
    @help = {}
    @help[:nmap] = %[A device profiling utility.]
    @help[:metric] = %[A sampling of server metrics.]
    @help[:help] = %[This help file.]
    #    @help.each_pair { |k,v| he << %[@nomad.#{k} => #{v}] }
    @help.map { |k,v| %[<p><code>@nomad.#{k}</code><span>#{v}</span></p>] }.join("")
  end
  def self.nmap *a
    `nmap #{a.join(' ')}`.split("\n").map { |e| %[<p>#{e}</p>] }.join("")
  end
  def self.metric m
    Metric.new(m).to_h.map { |k,v| %[<p>#{v}: #{k}</p>] }.join("")
  end
  def self.hub t
    if !@@HUB.has_key? t
      @@HUB[t] = IO.new(t)
    end
    return @@HUB[t]
  end
  def self.broker *c, &b
    @c = PahoMqtt::Client.new
    PahoMqtt.logger = 'paho_mqtt'
    @c.on_message { |m| b.call(m) }
    @c.connect('vango.me', 1883)
    c.each {|e| @c.subscribe([e.to_s, 2]) }
  end
  def self.mqtt h={}
    @c = PahoMqtt::Client.new
    @c.connect('vango.me', 1883)
    h.each_pair { |k,v| @c.publish(k.to_s, "#{v}", false, 1) }
  end
  def self.nomad
    puts "Running on #{`hostname`} #{`uname -a`}"
    puts "Ready at #{Time.now.utc}"
    puts "available commands: @nomad.help"
    puts "Good luck out there.  Don't do anything stupid."
    return self
  end
end
