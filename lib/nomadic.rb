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

  class Metric
    include Redis::Objects
    sorted_set :stat
    def initialize k
      @id = k
    end
    def id; @id; end
    def up k
      self.stat.incr(k)
    end
    def dn k
      self.stat.decr(k)
    end
    def to_h
      self.stat.members(with_scores: true).to_h
    end
  end
  class K
    include Redis::Objects
    hash_key :attr
    sorted_set :stat
    list :task
    list :note
    list :log
    def initialize u
      @id = u
      @prompt = ""
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
    def prompt *p
      @prompt = p[0]
    end
    def << i
      db = {}
      @pr = ''
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
          self.instance_eval(%[@b = lambda { #{i} };])
          o = @b.call
        rescue => re
          o = re
        end
        self.log << "cmd: #{i} at #{Time.now.utc.to_s}"
      end
      db[:stat] = self.stat.members(with_scores: true).to_h
      db[:attr] = self.attr.all
      db[:cmd] = t
      db[:input] = @prompt
      db[:output] = o;
      @db = db
      Redis.new.publish("vm.#{@id}", "#{@db}")
      return db
    end
  end 
  
  class App < Sinatra::Base
    HTML = %[
	      <DOCTYPE html>
		<head>
		  <style>
.i > *  { vertical-align: middle; font-size: medium; }
.i > button { text-align: center; padding: 0; }
		    .l { left: 0; }
		    .r { right: 0; }
		    code { border: thin solid black;  padding: 0 1% 0 1%; }
		    .action { border: thin dotted red; border-radius: 10px; }
		  </style>

<meta name="viewport" content="width=device-width, initial-scale=1.0">
<script src="https://code.jquery.com/jquery-3.5.1.min.js" integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin="anonymous"></script>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
	    </head>
	    <body style='height: 100%; width: 100%; margin: 0; padding: 0;'>
	    <form id='form' style='margin: 0, padding: 0;'>
  <datalist id='cmds'>
    <option value='[ ] '>
    <option value='tasks'>
    <option value='settings'>
    <option value='profile'>
    <option value='logs'>
    <option value='help'>
  </datalist>
    <p id='t' class='i' style='width: 100%; text-align: center; margin: 0;'>
      <button id='t_l' type='button' class='material-icons do' value='van'>airport_shuttle</button> 
      <input class='form' id='t_c' name='cmd' list="cmds" style='width: 60%; border: thin solid black;'>
      <button id='b_l' type='button' class='material-icons do' value='scan'>qr_code_scanner</button>
    </p>
    <fieldset style='height: 80%; overflow-y: scroll;'>
      <legend id='input'>welcome</legend>
      <div id='output'>#{WELCOME}</div>
    </fieldset>
   <p id='b' class='i' style='width: 100%; text-align: center; margin: 0; position: absolute; bottom: 0;'> 
      <button id='b_l' type='button' class='material-icons do' value='menu'>menu</button>                                                
      <input class='form' id='b_c' name='cmd' list="cmds" style='width: 60%; border: thin solid black;'>
      <button id='exe' type='button' class='material-icons do' value='send'>send</button>
    </p> 
  </form>
  <script>
    // get unique id OR use one passed in.
	var id = "<%= params[:id] || rand_id %>";
        var d = { id: id };
	// turn form into json object.
	function getForm() {
	    var ia = {};
            console.log("get", $("#form").serializeArray());
	    $.map($('.form'), function(n, i) { ia[$(n).attr('name')] = $(n).val(); }); return ia;
	}
	function sendForm(th) {
	    var dx = {};
	    Object.assign(dx, d);
	    dx.trigger = th;
	    dx.form = getForm();
	    console.log("send", dx);
            jQuery.post('/', dx, function(dd) {
		console.log("got", dd);
		d.time = dd.timestamp;
		$("#input").html(dd.cmd); 
		$("#output").html(dd.output);
		$("#form")[0].reset();
		if ( $("#b").val() == '' ) {
                    $("#b").val(dd.input);
		}
            });
	}
	
	
	$(function() {
	    //            setInterval(function() { sendForm('ping'); }, 10000);	    	
	    $(document).on('submit', "form", function(ev) { ev.preventDefault(); $("#exe").click(); });
	    $(document).on('click', ".task", function(ev) { 
		ev.preventDefault(); 
		$("#cmd").val("[X] " + $(this).val()); 
	    });
            $(document).on('keyup', '.form', function() {
                 var c = $(this).val();  
                 if (c.match(/ $/)) {
                   $("#do").css('color', 'orange'); 
                 } else if (c != "") {
                   $("#do").css('color', 'green'); 
                 } else {
                   $("#do").css('color', 'black');
                 }
            });
	    $(document).on('click', '.do', function(ev) { 
		ev.preventDefault(); 
		sendForm($(this).attr('value'));
	    });
	});
	</script>
	    </body>
</html>
        ]
    def initialize()
      super()
      @vm = Hash.new { |h,k| h[k] = K.new(k) }
      @metrics = Hash.new { |h,k| h[k] = Metric.new(k) }
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
    end
    before do
      @metrics[:referals].up request.referer
      Redis.new.publish "App.#{request.request_method}", "#{request.fullpath} #{params}"
    end
    get('/') {
        ERB.new(HTML).result(binding)
    }
    post('/') {
        content_type 'application/json';
        e = @vm[params[:id]] << params[:form][:cmd]
        return JSON.generate(e)
    }
    not_found do
      h = {
        method: request.request_method,
        host: request.host,
        port: request.port,
        path: request.fullpath,
        referer: request.referer,
        params: params
      }
      t = Time.now.utc.to_i
      Redis::Set.new("404s") << t
      Redis::HashKey.new("404")[t] = JSON.generate(h)
      Redis.new.publish "404.#{t}", JSON.generate(h)
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
