require 'redis-objects'
require 'json'
require 'paho-mqtt'
require 'cinch'

module Nomadic

  autoload :VERSION, "nomadic/version"

  WELCOME = [%[<h3>Welcome!</h3>],
             %[<h2>type your phone number above to begin</h2>],
             %[<h4>simple.</h4>],
             %[<h4>flexible.</h4>],
             %[<h4>tools.</h4>]].join('')
  
  HELP = [%[<h2>Remain Calm.</h2>],
          %[<p>here's how you do some stuff!</p>],
          %[<h3>tools</h3><ul><li><span>settings</span><span>Show your session settings.</span></li><li><span>id</span><span>Show your id.</span></li><li><span>tasks</span><span>Show your remaining tasks.</span></li><li><span>logs</span><span>Show your session history.</span></li></ul>]].join('')

  SETTINGS = [%[settings...]].join('')
  
  class K
    include Redis::Objects
    hash_key :attr
    sorted_set :stat
    list :task
    list :note
    list :logs
    def initialize u
      @id = u
      @db = {}
    end
    def id; @id; end
    def help; HELP; end
    def settings; SETTINGS; end
    def logs
      self.logs.map { |e| %[<p>#{e}</p>] }.join('')
    end
    def tasks
      if self.task.length > 0
        self.task.map { |e|
        %[<p><button class='material-icons task' type='button' value='#{e}'>done</button><label class='r'>#{e}</label></p>]
      }.join('')
      else
        "done!"
      end
    end
    def << i
      db = {}
      if m = /^\[\s\]\s?(.*)?/.match(i)
        t = 'tasks'
        if m[1] != nil && m[1] != ''
          self.task << m[1]
          self.logs << "created task: #{m[1]} at #{Time.now.utc.to_s}"
        end
        o = tasks
      elsif m = /^\[X\]\s(.*)/.match(i)
        t = "tasks"
        self.task.delete(m[1])
        self.logs << "finished task: #{m[1]} at #{Time.now.utc.to_s}"
        o = tasks
      else
        t = i
        begin
          self.instance_eval %[@b = lambda { #{i} };]
          o = @b.call
        rescue => re
          o = re
        end
        self.logs << "cmd: #{i} at #{Time.now.utc.to_s}<br>#{o}"
      end
      db[:stat] = self.stat.members(with_scores: true).to_h
      db[:attr] = self.attr.all
      db[:cmd] = t
      db[:output] = o;
      @db = db
      return db
    end
  end
  
  @mqtt = PahoMqtt::Client.new()
  @mqtt.on_message do |m|
    puts "MQTT #{m.topic} #{m.payload}"
  end
  @mqtt.connect('vango.me', 1883)
  @mqtt.subscribe(['#', 1])
  def self.mqtt
    @mqtt
  end
  @tokens = Redis::HashKey.new('tokens')
  Process.detach(
    fork {
      loop {
        t = Time.now.utc
        r = []; 10.times { r << rand(16).to_s(16) }
        @tokens[r.join('')] = t.to_i
        @mqtt.publish("time", JSON.generate({ epoch: t.to_i, clock: t.to_s, token: r.join('') }))
        sleep 1
      }
    }
  )
  
  class App < Sinatra::Base
    INDEX = [
      %[<!DOCTYPE html><head>],
      %[<style>],
      %[form { width: 100%; }],
      %[#i > *  { vertical-align: middle; }],
      %[.l { left: 0; }],
      %[.r { right: 0; }],
      %[</style>],
      %[<script src="https://code.jquery.com/jquery-3.5.1.min.js" integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin="anonymous"></script>],
      %[<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">],
      %[</head><body style='height: 100%; width: 100%; margin: 0; padding: 0;'>],
      %[<datalist id='cmds'><option value='help'><option value='task '><option value='note '></datalist>],
      %[<form><h1 id='i' style='width: 100%; text-align: center; margin: 0;'><input id='cmd' list="cmds" style='width: 75%;'><button id='exe' type='button' class='material-icons'>send</button></h1>],
      %[<fieldset style='height: 100%;'><legend id='input'>nomadic</legend><div id='output'>This is the nomadic user interface.</div></fieldset>],
      %[</form><script>],
      %[var id = "<%= params[:id] || rand_id %>";],
      %[function getForm() {],
      %[var ia = {};],
      %[$.map($('form').serializeArray(), function(n, i) { ia[n['name']] = n['value']; });],
      %[return ia; }],
      %[$(function() {],
      %[$(document).on('submit', "form", function(ev) { ev.preventDefault(); $("#exe").click(); });],
      %[$(document).on('click', ".task", function(ev) { ev.preventDefault(); $("#cmd").val("[X] " + $(this).val()); });],
      %[$(document).on('click', "#exe", function(ev) { ev.preventDefault(); jQuery.post('/', { id: id, cmd: $("#cmd").val(), form: getForm() }, function(d) { console.log("post", d); if ( d.output ) { $("#output").html(d.output); $("#input").html(d.cmd);} }); $("#cmd").val(""); });],
      %[});],
      %[</script>]
    ];
    def initialize()
      super()
      @vm = Hash.new { |h,k| h[k] = K.new(k) }
    end
    helpers do
      def rand_id
        a = []; 16.times { a << rand(16).to_s(16) }; return a.join('')
      end
    end
    configure do
      set :bind, '0.0.0.0'
      set :port, 8080
    end
    before do
      puts "#{request.request_method} #{request.fullpath} #{params}"
    end
    get('/') {
      ERB.new(INDEX.join('')).result(binding)
    }
    post('/') {
      content_type 'application/json';
      e = @vm[params[:id]] << params[:cmd]
      return JSON.generate(e)
    }
  end
  def self.begin
    @bot = Cinch::Bot.new do
      configure do |c|
        c.nick = @id
        c.server = "vango.me"
        c.verbose = true
        c.channels = ['#hive', "##{@id}" ]
      end
      on(:catchall) {|m| puts "IRC #{m}" }
      def privmsg h
        Channel(h[:ch]).send(h[:msg])
      end
    end
    Process.detach( fork { @bot.start } )
    Process.detach( fork { App.run! } )
  end
  def bot h={}
    @bot.privmsg(h)
  end
end
