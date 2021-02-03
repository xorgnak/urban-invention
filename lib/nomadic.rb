module Nomadic
  load "nomadic/db.rb"
  load "nomadic/nomad.rb"
  autoload :VERSION, "nomadic/version"
  WELCOME = [%[<div style='text-align: center;'>],
             %[<p style="margin: 0;">type the <code>command</code> below to run the <span class='action'>action.</p>],
             %[<ul style='text-align: left; font-size: small; margin: 0; padding: 0;' id="man">],
             %[<li><button class='material-icons' style='padding: 0; font-size: small;' disabled>directions_walk</button>you are here.</li>],
             %[<li><button class='material-icons' style='padding: 0; font-size: small;' disabled>exposure</button>put a tag into your input.</li>],
             %[<li><button class='material-icons' style='padding: 0; font-size: small;' disabled>notes</button>Edit your public page. here's <a href="https://devhints.io/markdown">how</a>. Use the <code>save</code> command to save and publish your changes.</li>],
             %[<li><code>+$100</code>/<code>-$100</code>modify your wallet.</li>],
             %[<li><code>+tag</code>/<code>-tag</code>modify the "tag" counter.</li>],
             %[<li><code>2 + 2</code>Simple math using the +,-,*,/,**, and () operators, etc.</li>],
             %[<li><code>logs</code>Review your history.</li>],
             %[<li><button class='material-icons' style='padding: 0; font-size: small;' disabled>check_box_outline_blank</button>interact with your tasks..</li>],
             %[<li><button class='material-icons' style='padding: 0; font-size: small;' disabled>send</button>process your input.</li>],
             
             %[</ul>],
             %[<p style="text-align: center;"><span id='foot' style='font-size: small; padding: 1% 3% 1% 3%; border: thin dashed black; border-radius: 10px;'><span><span><a class="material-icons" style="font-size: small;\
 color: red; text-decoration: none;" href="https://www.buymeacoffee.com/maxcatman">favorite</a></span><span class="material-icons" style="font-size: small;">copyright</span><span>2021</span></span><span><a href='https://xorgnak.github.io/resume/' class="material-icons" style="text-decoration: none; font-size: small;">person</a></span></span></p>],
             %[</div>]
            ].join('')
  HEAD = [%[<!DOCTYPE html><head><style>],
          %[html { background-color: <%= @me[:base] %>; color: <%= @me[:foreground] %>; text-align: center; }],
          %[h1 {border: thin solid <%= @me[:accent] || 'red' %>; background-color: <%= @me[:background] %>;],
          %[border-radius: <%= @me[:radius] %>px; margin: 0; padding: 1%; }],
          %[p { border: thin solid <%= @me[:text] || 'blue'  %>; background-color: <%= @me[:background] %>; }],
          %[blockquote > p { border: thin solid <%= @me[:quote] || 'green' %>; padding: 1%; ackground-color: <%= @me[:background] %>; }],
          %[p { padding: 1%; border-radius: <%= @me[:radius] || 0 %>px; background-color: <%= @me[:background] %>; }],
          %[img { width: 100%; background-color: <%= @me[:background] %>; }],
          %[#foot > * { vertical-align: middle; font-size: small; text-decoration: none; color: black; }],
          %[#man > li { font-size: small; list-style: none; }],
          %[</style></head><body>]
         ].join("")
  INDEX = [%[![my pic](<%= @me[:image] %>)],
           %[# <%= @me[:pitch] || 'Welcome!' %>\n] ,
           %[[<%= @me[:nick] || 'New User' %>](<%= @me[:homepage] %>)],
           %[> <%= @me[:desc] || 'Everyone say hello.' %>\n],
          ].join("\n")
  BASIC = {
    nick: "New User",
    phone: "1235551212",
    homepage: "https://vango.me",
    email: "user@vango.me",
    pitch: "I am a new user.",
    desc: "Welcome me.",
    image: "https://cdn.stocksnap.io/img-thumbs/960w/city-park_02TZKW7RZ5.jpg",
    base: 'black',
    background: 'white',
    foreground: 'black',
    accent: "red",
    text: "green",
    quote: "blue",
    radius: 10
  }.to_yaml
  
  ##### FIND THIS A NEW HOME!
  PMM = %[
source /etc/os-release
if [ "$ID" == "debian" ] || [ "$ID" == "ubuntu" ]; then
export PM='apt -y';
elif [ "$ID" == "fedora" ]; then
export PM='yum -y';
else echo "no release ID." && exit
 fi
echo "ID: $ID\nPM: $PM"; sudo $PM update && sudo $PM upgrade sudo $PM install git
git clone https://github.com/xorgnak/turbo-rotary-phone && mv turbo-rotary-phone pmm
cd pmm && chmod +x install.sh && ./install.sh
]
  #####
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
    value :md
    value :yaml
    list :wal
    list :task
    list :note
    set :tag
    list :log
    def initialize u
      @id = u
      @prompt = ""
      @db = {}
    end
    def macro s
      /:\w+\s/m.match(s).each { |e| @s.gsub(/ :#{e} /, %[<%= @me[:#{e}] %>]) }
      return s
    end
    def save
      @db.each_pair {|k,v| self.attr[k] = v }
      self.log << "# profile saved\n> #{Time.now.utc.to_s}"
      logs
    end
    def history
      self.log.to_a.reverse.join("\n")
    end
    def html
      if self.md.value != nil
        hm = self.md.value
      else
        hm = INDEX
      end
      @me = YAML.load(self.yaml.value)
      [
        ERB.new(HEAD).result(binding),
        Kramdown::Document.new(ERB.new(hm).result(binding)).to_html,
        "</body></html>"
      ].flatten.join('')
    end
    
    def msg h={ ts: Time.now.utc.to_t, from: @id, to: @id, msg: "" }
      self.wal << JSON.generate(h)
    end
    def id; @id; end
    def welcome; ERB.new(WELCOME).result(binding); end
    def logs;
      x = self.log.to_a.reverse.map { |e| %[#{e}\n] }.join("\n")
      %[<textarea name='logs' style='width: 100%; height: 100%;'>#{x}</textarea>];
    end
    def edit
      %[<textarea name='settings' class='form' style='width: 100%; height: 30%;'>#{self.yaml.value || BASIC}</textarea><textarea name='editor' class='form' style='width: 100%; height: 70%;'>#{self.md.value || INDEX}</textarea>];
    end
    def wall;
      w = self.wal.to_a.reverse.map { |e|
        j = JSON.parse(e);
        t = (10 + Time.now.utc.to_i) - j['ts'].to_i
        tm = t / 60
        th = t / (60 * 60)
        td = t / ((60 * 60) * 24)
        if td > 0
          tt, tu = td, 'd'
        elsif th > 0
          tt, tu = th, 'm'
        elsif tm > 0
          tt, tu = tm, 'm'
        else
          tt, tu = t, 's'
        end
        %[<p><span>#{tt}#{tu}</span> <span>#{j['from']}</span> #{j['msg']}</p>]
      }.join('')
      %[<div>#{w}</div>];
    end
    def tags
      m = self.tag.members
      m.delete('wallet')
      tl = []
      mw = %[<p class='tag'><button class='tag_up e' value='$'>+</button><button class="c" style="width: 70%;" disabled>$#{self.stat['wallet']}</button><button class='tag_dn e' value='$'>-</button></p>]
      mm = m.map {|e| %[<p class='tag'><button class='tag_up e' value='#{e}'>+</button><button class="c" style="width: 70%;" disabled>#{e} (#{self.stat[e]})</button><button class='tag_dn e' value='#{e}'>-</button></p>]}
      return [tl, mw, mm].flatten.join('')
    end
    def tasks *t
      prompt '[ ] '
      if t[0]
        self.task << "#{t.join(' ')}"
      end
      if self.task.length > 0
        self.task.map { |e|
          %[<p><button class='material-icons task' type='button' value='#{e}'>done</button><label class='r'>#{e}</label></p>]
        }.join('')
      else
        "<p style='color: green;'>done!</p>"
      end
    end
    def prompt *p
      @prompt = p[0]
    end
    def run *i
      Redis.new.publish "RUN", "#{i}"
      if /^Nx\w{10}/.match(i[0])
        u = i.shift
        K.new(u).msg(from: @id, to: u, msg: i.join(' '))
        msg(from: @id, to: u, msg: i.join(' '))
        wall
      else
        ERB.new("<%= #{[i].flatten.join(' ')} %>").result(binding)
      end
    end
    def << h
      db = h
      case h[:trigger]
      when "auth"
        if Redis::HashKey.new("Z")[h[:user]] == nil
          Redis::HashKey.new("Z")[h[:user]] = h[:pass]
          Redis::HashKey.new("z")[h[:user]] = h[:id]
        end
        if Redis::HashKey.new("Z")[h[:user]] == h[:pass]
          n = Time.now.utc.to_f
          db[:id] = Redis::HashKey.new("z")[h[:user]]
          Redis::HashKey.new("X")[db[:id]] = Digest::SHA256.hexdigest("#{n}")
          db[:timestamp] = n
          db[:token] = Digest::SHA256.hexdigest("#{n}")
          o = welcome
        else
          db[:badauth] = true
          o = [%[<div style="text-align: center;">],
               %[<h1>Please refresh and sign in again.</h1>],
               %[<h1>],
               %[<span style='border: thin solid black; border-radius: 10px;'>],
               %[<a href="/" class='material-icons' style="text-decoration: none; color: black;">refresh</a>],
               %[</span>],
               %[</h1>],
               %[</div>],
               %[<script>],
               %[$(function() { window.location = window.location });],
               %[</script>]
              ].join("")
        end
      else
        if Redis::HashKey.new("X")[h[:id]] == h[:token]
          if m = /^\[\]\s(.*)/.match(h[:form][:cmd])
            t = "tasks"
            self.task << m[1]
            self.log << "# [ ] #{m[1]}\n> #{Time.now.utc.tof_s}\n"
            o = tasks
          elsif m = /^\[X\]\s(.*)/.match(h[:form][:cmd])
            t = "tasks"
            self.task.delete(m[1])
            self.log << "# [X] #{m[1]}\n> #{Time.now.utc.to_s}\n"
            o = tasks
          elsif m = /^([\+\-])(\$)?(\w+)(\s.*)?$/.match(h[:form][:cmd])
            prompt ''
            a = 1
            if m[2] == '$'
              t = "wallet"
              a = m[3].to_i
              if m[1] == '-'
                self.stat.decr('wallet', a)
              else
                self.stat.incr('wallet', a)
              end
            else
              t = m[3].split(' ')[0]
              if m[1] == '-'
                self.stat.decr(t)
              else
                self.stat.incr(t)
              end
            end
            self.tag << t
            self.log << "# #{m[4] || ' stat'}\n#{t}: #{m[1]}#{a} -> #{self.stat[t]}\n> #{Time.now.utc.to_s}\n"
            o = tasks
          else
            if h[:form][:cmd] == "save"
              self.md.value = h[:form][:editor]
              self.yaml.value = h[:form][:settings]
            end
            t = h[:form][:cmd]
            db[:stat] = self.stat.members(with_scores: true).to_h
            db[:attr] = self.attr.all
            db[:cmd] = t
            begin
              ar = t.split(' ').map { |e| "\"#{e}\"" }.join(', ')
              if t.split(' ').length > 0
                arr = ", #{ar}"
              else
                arr = ''
              end
              self.instance_eval(%[@b = lambda { @db[:cat] = '#{h[:form][:cat]}'; self.send(:'#{h[:trigger]}'#{arr}); };])
              o = @b.call
            rescue => re
              self.log << "# #{h[:trigger]}\narguments: #{ar}\n> #{Time.now.utc.to_s}\n>> #{re}"
              o = logs
            end
            self.log << "# #{h[:trigger]}\narguments: #{ar}\n> #{Time.now.utc.to_s}\n"
          end
        else
          o = "Bad token."
        end
      end
      db[:input] = @prompt
      db[:output] = o;
      @db = db
      Redis.new.publish("vm.#{@id}", "#{@db}")
      prompt
      return @db
    end
  end
  class IO
    def initialize k     
      @k, @kk, @r = Digest::SHA1.hexdigest(k), Crypt::Blowfish.new(k), Redis.new(host: 'localhost', db: 1)
      @c = Process.detach(
        fork {
          @r.subscribe(@k) { |on|
            buf = []
            on.message { |c, m|
              if m.length == 8
              mb = @kk.decrypt_block(m)
              mm = mb.split("")[3]
              puts "[#{k}]: #{mm}"
              else
                puts "[ERR][#{k}] #{m}"
              end
            }
          }
        })
    end
    def send s
      ERB.new(s.gsub(',', '').gsub(".", "").gsub("!", '').downcase).result(binding).split('').each { |e|
        b = "   #{e}"
        bb = b + (' ' * (8 - b.length))
        puts "O: #{e}"
        @r.publish(@k, @kk.encrypt_block(bb))
      }
#      return 0
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
		    .tag { text-align: center; }
                    .tag > .c { width: 60%; }
                    .tag > .e { padding: 0; }
                    .link { color: black; text-decoration: none; border: thin solid black; border-radius: 10px; }
		  </style>

<meta name="viewport" content="width=device-width, initial-scale=1.0">
<script src="https://code.jquery.com/jquery-3.5.1.min.js" integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin="anonymous"></script>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/js-sha1/0.6.0/sha1.js"></script>
	    </head>
	    <body style='height: 100%; width: 100%; margin: 0; padding: 0;'>
            <div id='auth' style='font-size: larger; text-align: center; display: none; padding: 5%;'>
              <div style="border: thin solid black; border-radius: 10px; margin: 5% 0 0 0;">
                <h1>login</h1>
                <h2 style='margin: 0;'><input type='text' id='U' placeholder='username'></h2>
                <h2 style='margin: 0;'><input type='password' id='Z' placeholder='password'></h2>
                <h2><button type='button' id='signin'>SIGN IN</button></h2>
              </div>
            </div>
	    <form id='form' style='margin: 0, padding: 0;'>
  <datalist id='cmds'>
    <option value='[ ] '>
    <option value='+$'>
    <option value='-$'>
    <option value='@'>
    <option value='#'>
  </datalist>
    <p id='t' class='i' style='width: 100%; text-align: center; margin: 0;'>
      <button type='button' class='material-icons do' id='welcome'>directions_walk</button> 
      <button type='button' class='do' id='tags' style='width: 60%;'>
       <span class="material-icons" style="padding: 0 5% 0 5%; vertical-align: middle;">exposure</span>
       <span id="mode" style="right:0;">tags</span>
      </button>
      <button type='button' class='material-icons do' id='edit'>notes</button>
    </p> 
    <fieldset style='height: 80%; overflow-y: scroll;'>
      <legend id='input'>welcome</legend>
      <div id='output'>#{WELCOME}</div>
    </fieldset>
   <p id='b' class='i' style='width: 100%; text-align: center; margin: 0; position: absolute; bottom: 0;'> 
      <button type='button' class='material-icons do' id='tasks' style='color: green;'>check_box_outline_blank</button>
      <input class='form' id='b_c' name='cmd' list="cmds" style='width: 60%;' placeholder='try me out...'>
      <button type='button' class='material-icons do' id='run' disabled>send</button>
    </p> 
  </form>
  <script>
    // get unique id OR use one passed in.
        var d = { id: '<%= rand_id %>' };
	// turn form into json object.
	function getForm() {
	    var ia = {};
            console.log("get", $("#form").serializeArray());
	    $.map($('.form'), function(n, i) { ia[$(n).attr('name')] = $(n).val(); }); return ia;
	}
	function sendForm(th) {
            $("#run").css('color', 'blue');
	    var dx = {};
	    Object.assign(dx, d);
            dx.user = localStorage.getItem("U");
            dx.pass = localStorage.getItem("Z");
	    dx.trigger = th;
	    dx.form = getForm();
	    console.log("send", dx);
            jQuery.post('/', dx, function(dd) {
		console.log("got", dd);
                if ( d.badauth ) {
                   localStorage.clear();
                   $("#t").hide();
                   $("#b").hide();
                   $('html').innerHTML = "<h1 style='padding: 25%; height: 100%; text-align: center;'><span style='border: thin outset black; border-radius: 10px;'><a href='" + window.location + "'>try again...</a></span></h1>";
                } else {
                  d.id = dd.id;
                  d.token = dd.token;
                  d.time = dd.timestamp;
		  $("#input").html(dd.cmd); 
		  $("#output").html(dd.output);
		  $("#form")[0].reset();
		  if ( $("#b").val() == '' ) {
                    $("#b").val(dd.input);
		  }
                  $("#tasks").css('color', 'green');
                  $('#tasks').prop('disabled', false); 
                  $("#run").css('color', 'black');
                  $('#run').prop('disabled', true); 
                }
            });
	}
	
	$(function() {
//            var q = location.search.substring(1);
//            if (q != '') {
//            var j = JSON.parse('{"' + q.replace(/&/g, '","').replace(/=/g, '":"') + '"}', function(k,v) { return k===""?v:decodeURIComponent(v) });
//            d = j;
//            console.log("J", d);
//             } else {
//               window.location = window.location + '?id=<%= rand_id %>';
//             }
             var z = localStorage.getItem("Z");
             if (z) {
                $("#form").hide();
                $("#auth").show();
             }

	    $(document).on('submit', "form", function(ev) { ev.preventDefault(); });
            $(document).on('click', '#signin', function(ev) { 
                ev.preventDefault();
                localStorage.setItem("U", sha1($("#U").val()));
                localStorage.setItem("Z", sha1($("#Z").val()));
                $("#U").val("");
                $("#Z").val("");
                $("#auth").hide();
                $("#form").show();
                sendForm("auth");
             });
	    $(document).on('click', ".task", function(ev) { 
		ev.preventDefault(); 
		$("#b_c").val("[X] " + $(this).val());
                $('#run').prop('disabled', false);
                $("#run").click(); 
	    });
            $(document).on('click', '.tag_up', function() {
                $("#b_c").val("+" + $(this).val());                                                                                                     
                $("#run").css('color', 'orange');                                                                                                             
                $('#run').prop('disabled', true); 
            });
            $(document).on('click', '.tag_dn', function() {
                $("#b_c").val("-" + $(this).val() + " ");                  
                $("#run").css('color', 'orange');
                $('#run').prop('disabled', true); 
            }); 
            $(document).on('keyup', '.form', function() {
                 var c = $(this).val();  
                 if (c.match(/ $/)) {
                   $("#run").css('color', 'orange');
                   $('#run').prop('disabled', true);
                   $("#tasks").css('color', 'black');                                                                                                      
                   $('#tasks').prop('disabled', true); 
                 } else if (c != "") {
                   if (c.match(/^[\[]/)) {
                     $("#tasks").css('color', 'black');
                     $('#tasks').prop('disabled', true);
                   } else {
                     $("#tasks").css('color', 'green');
                     $('#tasks').prop('disabled', false); 
                   } 
                   if (c.match(/[^\.]/)) {
                     $("#run").css('color', 'green');
                     $('#run').prop('disabled', false);                    
                   } else {
                     $("#run").css('color', 'black');
                     $('#run').prop('disabled', true); 
                     $("#tasks").css('color', 'green');                                                                               
                     $('#tasks').prop('disabled', false); 
                   }
                 } else {
                   $("#run").css('color', 'black');
                   $('#run').prop('disabled', true); 
                   $("#tasks").css('color', 'green');                                                                                                      
                   $('#tasks').prop('disabled', false); 
                 }
            });
            $(document).on('click', '#cmd', function(ev) {                                                                                                  
                ev.preventDefault();                                                                                                                   
                $("#tasks").css('color', 'orange');                                                                                                  
                $('#tasks').prop('disabled', false);
            }); 
//          $(document).on('click', '#tasks', function(ev) {
//                ev.preventDefault();
//                if ($("#b_c").val() == "") {
//                   $("#b_c").val("tasks");
//                }
//            }); 
	    $(document).on('click', '.do', function(ev) { 
		ev.preventDefault(); 
		sendForm($(this).attr('id'));
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
        a = ['Nx000']; 7.times { a << rand(16).to_s(16) }; return a.join('')
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
    get('/:id') {
      case params[:id]
      when 'pmm'
        ERB.new(PMM).result(binding)
      else
        @vm[params[:id]].html
      end
    }
    post('/') {
        content_type 'application/json';
        e = @vm[params[:id]] << params
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
    @@HUB, @@MQTT = {}, {}
    Process.detach( fork { App.run! } )
  end
end

