module Nomadic
  def self.methods
    self.instance_methods
  end
  def self.help
    he = []
    @help = {}
    @help[:nmap] = %[A device profiling utility.]
    @help[:hub] = %[A decentralized messaging handler.]
    @help[:broker] = %[Broker incomming mqtt traffic.]
    @help[:mqtt] = %[Send mqtt messages by topic.]
    @help[:db] = %[The interface to the local nomadic database.]
    @help.each_pair { |k,v| he << %[@nomad.#{k} => #{v}] }
    puts ERB.new(he.join("\n")).result(binding)
  end
  def self.nmap *a
    `nmap #{a.join(' ')}`.split("\n")
  end
  def self.metric m
    Metric.new(m).to_h
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
