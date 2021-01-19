module Nomadic

  autoload :VERSION, "nomadic/version"

  NOMADIC = [ %[<div style='text-align: center;'>], 
              %[<p>a simple set of tools to work together and get things done.</p>],
              %[<h1 class='material-icons'>],
              %[<span style='padding: 2%; background-color: black; color: white; border-radius: 10px; font-size: 300%;'>directions_walk</span>],
              %[</h1>],
              %[<p>lovingly crafted by <a href='https://github.com/xorgnak'>this</a> guy.</p>],
              %[</div>]
            ].join('');
  
  WELCOME = [%[<div style='text-align: center;'>],
             %[<h2>type your phone number above to begin</h2>],
             %[<h4>simple. flexible. tools.</h4>],
             %[<h1 class='material-icons'>],
             %[<span style='padding: 2%; background-color: black; color: white; border-radius: 10px; font-size: 300%;'>directions_walk</span>],
             %[</h1>],
            %[</div>]].join('')
  
  HELP = [%[<h2 style='text-align: center;'>Remain Calm.</h2>],
          %[<p>type the <code>command</code> below to run the <span class='action'>action</span>.</p>],
          %[<ul>],
          %[<li><code>[ ] my new task.</code><span class='action'>Create a new task.</span></li>],
          %[<li><code>settings</code><span class='action'>Show your session settings.</span></li>],
          %[<li><code>id</code><span class='action'>Show your user id.</span></li>],
          %[<li><code>tasks</code><span class='action'>Show your remaining tasks.</span></li>],
          %[<li><code>logs</code><span class='action'>Show your session history.</span></li>],
          %[<li><code>help</code><span class='action'>Show this help.</span></li>],
          %[<li><code>2 + 2</code><span class='action'>Simple math using the +,-,*,/,**, and () operators.</span></li>],
          %[</ul>]].join('')

  SETTINGS = [%[settings...]].join('')
  
  class K
    include Redis::Objects
    hash_key :attr
    sorted_set :stat
    list :task
    list :note
    list :log
    def initialize u
      @id = u
      @db = {}
    end
    def id; @id; end
    def welcome; WELCOME; end
    def nomadic; NOMADIC; end
    def help; HELP; end
    def settings; SETTINGS; end
    def logs
      self.log.map { |e| %[<p>#{e}</p>] }.join('')
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
          self.log << "created task: #{m[1]} at #{Time.now.utc.to_s}"
        end
        o = tasks
      elsif m = /^\[X\]\s(.*)/.match(i)
        t = "tasks"
        self.task.delete(m[1])
        self.log << "finished task: #{m[1]} at #{Time.now.utc.to_s}"
        o = tasks
      else
        t = i
        begin
          self.instance_eval %[@b = lambda { #{i} };]
          o = @b.call
        rescue => re
          o = re
        end
        self.log << "cmd: #{i} at #{Time.now.utc.to_s}"
      end
      db[:stat] = self.stat.members(with_scores: true).to_h
      db[:attr] = self.attr.all
      db[:cmd] = t
      db[:output] = o;
      @db = db
      return db
    end
  end 
  
  class App < Sinatra::Base
    HTML = %[
<DOCTYPE html>
  <head>
    <style>
      #i > *  { vertical-align: middle; font-size: medium; }
      .l { left: 0; }
      .r { right: 0; }
      code { border: thin solid black;  padding: 0 1% 0 1%; }
      .action { border: thin dotted red; border-radius: 10px; }
    </style>

<meta name="viewport" content="width=device-width, initial-scale=1.0">
<script src="https://code.jquery.com/jquery-3.5.1.min.js" integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/paho-mqtt/1.0.1/mqttws31.min.js" type="text/javascript"></script>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
</head>
<body style='height: 100%; width: 100%; margin: 0; padding: 0;'>
  <datalist id='cmds'>
    <option value='[ ] '>
    <option value='tasks'>
    <option value='logs'>
    <option value='sessions'>
    <option value='id'>
    <option value='help'>
  </datalist>
  <form style='width: 100vw; height: 100vh; margin: 0;'>
    <p id='i' style='width: 100%; text-align: center; margin: 0;'>
      <button id='van' value='go' type='button' class='material-icons do' style=''>airport_shuttle</button> 
      <input id='cmd' list="cmds" style='width: 65%; border: thin solid black;'>
      <button id='do' type='button' class='material-icons' style=''>send</button>
	    </p>
    <fieldset id='out' style='height: 90%; overflow: auto;'>
      <legend id='input'>welcome</legend>
      <div id='output'>#{WELCOME}</div>
    </fieldset>
  </form>
	    <script>
	    // get unique id OR use one passed in.
	var id = "<%= params[:id] || rand_id %>";
        var state = { stage: 0 };
	// turn form into json object.
	function getForm() {
	    var ia = {};
	    $.map($('form').serializeArray(), function(n, i) { ia[n['name']] = n['value']; }); return ia;
	}
	// sends a message over mqtt
	function sendForm(th) {
            var d = { id: id, trigger: th, form: getForm() };
            ws.send(JSON.stringify(d));
	}
	$(function() {
	    // create the mqtt client.
            ws = new WebSocket('ws://vango.me');
	    
	    // set callback handlers
	    ws.onopen = function() { console.log("open") };
	    ws.onclose = function() { console.log("closed"); };
	    ws.onmessage = function(m) {
		console.log("onmessage", m);
	    };
	    
	    $(document).on('submit', "form", function(ev) { ev.preventDefault(); $("#exe").click(); });
	    $(document).on('click', ".task", function(ev) { 
		ev.preventDefault(); 
		$("#cmd").val("[X] " + $(this).val()); 
	    });
	    $(document).on('click', '#add', function(ev) {
		ev.preventDefault();
		$("#adds").toggle();
		
	    });
	    $(document).on('click', '.do', function(ev) { 
		ev.preventDefault(); 
		sendForm($(this));
	    });
	    $(document).on('click', "#do", function(ev) { 
		ev.preventDefault();
		sendForm($(this));
		$("form").reset();	
	    });
	});
	</script>
	    </body>
</html>
        ]
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
      set :server, 'thin'
      set :sockets, []
    end
    before do
      puts "#{request.request_method} #{request.fullpath} #{params}"
    end
    get('/') {
      if !request.websocket?
        ERB.new(HTML).result(binding)
      else
        request.websocket do |ws|
          ws.onopen do
            ws.send("SYN")
          end
          ws.onmessage do |msg|
            EM.next_tick { settings.sockets.each { |s| s.send(msg) } }
          end
          ws.onclose do
            settings.sockets.delete(ws)
          end
        end
      end
    }
    post('/') {
        content_type 'application/json';
        e = @vm[params[:id]] << params[:cmd]
        return JSON.generate(e)
    }
    not_found do
      Redis.new.publish "404", JSON.generate({
                                               method: request.request_method,
                                               host: request.host,
                                               port: request.port,
                                               path: request.fullpath,
                                               referer: request.referer,
                                               params: params
                                             })
    end
  end
  def self.begin
    @bot = Cinch::Bot.new do
      configure do |c|
        c.nick = @id
        c.server = "vango.me"
#        c.verbose = true
        c.channels = ['#hive', "##{@id}" ]
      end
      on(:catchall) {|m| puts "IRC #{m}" }
      def privmsg h
        Channel(h[:ch]).send(h[:msg])
      end
    end
#    Process.detach( fork { @bot.start } )
    Process.detach( fork { App.run! } )
  end
  def bot h={}
    @bot.privmsg(h)
  end
end
