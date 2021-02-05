module Nomadic
  ######
  #
  #
  # NOMADIC HUB
  #
  #
  ######
  #
  ##
  # OVERVIEW
  # - One nomadic server can handle many domains in which users may or
  # may not overlap.
  # - It is designed to get running and working as fast as possible and
  # to be as light on system resources but still allow flexibility and
  # customization as possible.
  # - It is not designed for comfort of developers, users, or anything
  # that can pass a touring test.
  # - Machines of all sizes love it.
  #
  ##
  # CONFIGURATION
  ##
  # Network Prefix
  # 
  # the identifier of the id on the overall nomadic network. Equivelent
  # to '1' for the original btc addresses, or 1z for ups tracking codes.
  # Same idea, just your own slight varient.
  PREFIX = "Nx"
  ##
  # Should we cluster to a master hub?
  #
  # If you set this to your master hub domain/ip address, your hub will
  # share all of it's data with it's client users and allow their hubs
  # to connect to it to share it's data.  You should probably both know
  # what you're doing if you're reading this and file an issue in the
  # github for further configuration advice.
  CLUSTER = false
  ##
  # On a scale of 0 to 4, how private is this hub?
  #
  #             0 <-----------[ 2 ]------------->  4
  #          (private)     (semi-private)      (public)
  #          [deck]          [hive]            [google]
  #
  # Moving this setting up with reduce the maximum available privledge
  # a user can have on the system.
  # - sets the minimum user id creation possible.  Lower has higher
  # privledge with all Nx0000000000 always being the hive itself.
  # - sets the $SAFE level in the cmd input.  0 can do anything they want.
  # Great to let kids play on a raspberry pi that's not connected to a
  # network.  Very BASIC.  Anything above 3 sets $SAFE to 3 and imposes
  # further restrictions on the redis server and mqtt broker.
  SAFETY = 0
  #
  ##
  # Route Function
  #
  # catalog: each route is the public interface for a single user or
  # group. Has a basic command interface.  Great for sales and
  # marketing teams or for keeping your grocery list.
  #
  # world: each route is a specific area complete with it's own content
  # and interactions. Each element has a gridsquare location in 256,256,256
  # space. Has tools to dynamically create content.
  #
  # none: no public routes.  Just the basic tools.
  FUNCTION = "catalog"
  #
  ##
  # Forking
  #
  # If you've read this far, you should probably just go ahead and fork
  # the repo at https://github.com/xorgnak/urban-invention, and note
  # your changes accordingly.
  
  load "nomadic/db.rb"
  load "nomadic/nomad.rb"
  load "nomadic/world.rb"
  autoload :VERSION, "nomadic/version"
  WELCOME = [%[<div style='text-align: center;'>],
             %[<p style="margin: 0;">type the <code>command</code> below to run the <span class='action'>action.</p>],
             %[<ul style='text-align: left; font-size: small; margin: 0; padding: 0;' id="man">],
             %[<li><button class='material-icons' style='padding: 0; font-size: small;' disabled>directions_walk</button>you are here.</li>],
             %[<li><button class='material-icons do' id="tools" style='padding: 0; font-size: small;'>backpack</button>other userful tools.</li>],
             %[<li><button class='material-icons do' id="tags" style='padding: 0; font-size: small;'>exposure</button>count money and other things.</li>],
             %[<li><button class='material-icons do' id="edit" style='padding: 0; font-size: small;'>notes</button>Edit your public page. here's <a href="https://devhints.io/markdown">how</a>. Use the <code>save</code> command to save and publish your changes.</li>],
             %[<li><code>+$100</code>/<code>-$100</code>modify your wallet.</li>],
             %[<li><code>+tag</code>/<code>-tag</code>modify the "tag" counter.</li>],
             %[<li><code>2 + 2</code>Simple math using the +,-,*,/,**, and () operators, etc.</li>],
             %[<li><code>logs</code>Review your history.</li>],
             %[<li><button class='material-icons' style='padding: 0; font-size: small;' disabled>check_box_outline_blank</button>interact with your tasks..</li>],
             %[<li><button class='material-icons' style='padding: 0; font-size: small;' disabled>send</button>process your input.</li>],
             
             %[</ul>],
             %[<p style="text-align: center;"><span id='foot' style='font-size: small; padding: 1% 3% 1% 3%; border: thin dashed black; border-radius: 10px;'><span><span><a class="material-icons" style="font-size: small; color: red; text-decoration: none;" href="https://www.buymeacoffee.com/maxcatman">favorite</a></span></span><span><a href='https://xorgnak.github.io/resume/' class="material-icons" style="text-decoration: none; font-size: small;">person</a></span></span></p>],
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
  # user sandbox
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
    set :grp
    list :log
    def initialize u
      @id = u
      @prompt = ""
      @msg = "connected."
      @db = {}
      @nomad = Nomadic.nomad
    end
#    def macro s
#      /:\w+\s/m.match(s).each { |e| @s.gsub(/ :#{e} /, %[<%= @me[:#{e}] %>]) }
#      return s
    #    end

    # store state
    def save
      @db.each_pair {|k,v| self.attr[k] = v }
      self.log << "# profile saved\n> #{Time.now.utc.to_s}"
      logs
    end
    
    # txt history
    def history
      self.log.to_a.reverse
    end

    # compile markdown from yaml and render
    def html
      if FUNCTION != 'none'
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
    end
    
    def msg h={ ts: Time.now.utc.to_i, from: @id, to: @id, msg: "" }
      self.wal << JSON.generate(h)
    end
    def id; @id; end
    def card
      %[<p><button type='button' class="material-icons" onclick="cp('#{@id}')">badge</button>#{@id}</p><p>share your id with your friends. write on their wall them with their id then a message.</p>]
    end
    def tools
      [%[<p><button type='button' class='material-icons do' id='logs'>book</button>review your history.</p>],
       %[<p><button type='button' class='material-icons' onclick="window.location = 'https://zoom.us/'">message</button>meet and greet.</p>],
       %[<p><button type='button' class='material-icons' onclick="window.location = 'https://github.com/xorgnak/urban-invention/issues/new?labels=bug'" >bug_report</button>found a bug?</p>],
       %[<p><button type='button' class='material-icons' onclick="window.location = 'https://voice.google.com'" >call</button>make some calls.</p>],
       %[<p><button type='button' class='material-icons' onclick="window.location = 'https://gmail.com'" >all_inbox</button>check your email.</p>],
       %[<p><button type='button' class='material-icons' onclick="window.location = 'https://drive.google.com'" >work</button>get some work done.</p>],
       %[<p><button type='button' class='material-icons' onclick="window.location = 'https://youtube.com'" >live_tv</button>Watch videos.</p>],
      ].join("")
    end

    # display welcome content.
    def welcome; ERB.new(WELCOME).result(binding); end

    # display logs.
    def logs;
      x = history.map { |e| %[#{e}\n] }.join("\n")
      %[<textarea name='logs' style='width: 100%; height: 100%;'>#{x}</textarea>];
    end

    # edit markdown and yaml
    def edit
      @prompt = "save"
      %[<textarea name='settings' class='form' style='width: 100%; height: 30%;'>#{self.yaml.value || BASIC}</textarea><textarea name='editor' class='form' style='width: 100%; height: 70%;'>#{self.md.value || INDEX}</textarea>];
    end

    # display tags
    def tags
      @prompt = '#'
      m = self.tag.members
      m.delete('wallet')
      tl = []
      mw = %[<p class='tag'><button class='tag_up e' value='$'>+</button><button class="c" style="width: 70%;" disabled>$#{self.stat['wallet']}</button><button class='tag_dn e' value='$'>-</button></p>]
      mm = m.map {|e| %[<p class='tag'><button class='tag_up e' value='#{e}'>+</button><button class="c look" value='#{e}' style="width: 70%;">#{e} (#{self.stat[e]})</button><button class='tag_dn e' value='#{e}'>-</button></p>]}
      return [tl, mw, mm].flatten.join('')
    end

    # display tasks
    def tasks *t
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

    # internal eval
    def run *i
      ERB.new("<%= #{[i].flatten.join(' ')} %>").result(binding)
    end

    # display msg
    def msg m
      @msg = m
    end
    
    # input handler
    def eval h
      Redis.new.publish "DEBUG", "#{h}"
      @db = { pipe: h["pipe"] }
      if h['trigger']
        case h['trigger']
        when "auth"
          if Redis::HashKey.new("Z")[h["user"]] == nil
            Redis::HashKey.new("Z")[h["user"]] = h["pass"]
            Redis::HashKey.new("z")[h["user"]] = h["id"]
          end
          if Redis::HashKey.new("Z")[h["user"]] == h["pass"]
            n = Time.now.utc.to_f
            @db[:id] = Redis::HashKey.new("z")[h["user"]]
            Redis::HashKey.new("X")[@db[:id]] = Digest::SHA256.hexdigest("#{n}")
            @db[:token] = Digest::SHA256.hexdigest("#{n}")
            @db[:ws] = "connected!"
            o = welcome
          else
            @db[:badauth] = true
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
          if Redis::HashKey.new("X")[h["id"]] == h["token"]
            if m = /^\[\]\s(.*)/.match(h["form"]["cmd"])
              t = "tasks"
              self.task << m[1]
              self.log << "# [ ] #{m[1]}\n> #{Time.now.utc.tof_s}\n"
              o = tasks
            elsif m = /^\[X\]\s(.*)/.match(h["form"]["cmd"])
              t = "tasks"
              self.task.delete(m[1])
              self.log << "# [X] #{m[1]}\n> #{Time.now.utc.to_s}\n"
              o = tasks
            elsif m = /^([\+\-])(\$)?(\w+)(\s.*)?$/.match(h["form"]["cmd"])
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
              Redis::Set.new("group:#{t}") << @id
              self.tag << t
              self.log << "# #{m[4] || ' stat'}\n#{t}: #{m[1]}#{a} -> #{self.stat[t]}\n> #{Time.now.utc.to_s}\n"
              o = tags
            else
              if h["form"]["cmd"] == "save"
                self.md.value = h["form"]["editor"]
                self.yaml.value = h["form"]["settings"]
              end
              t = h["form"]["cmd"]
              begin
                ar = t.split(' ').map { |e| "\"#{e}\"" }.join(', ')
                if t.split(' ').length > 0
                  arr = ", #{ar}"
                else
                  arr = ''
                end
                if FUNCTION == 'world'
                  @world = World.new(PREFIX)
                end
                self.instance_eval(%[@b = lambda { $SAFE = #{SAFETY}; self.send(:'#{h["trigger"]}'#{arr}); };])
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
        @db[:ws] = @msg
        @db[:cmd] = @prompt
        @db[:input] = t
        @db[:output] = o;
        @db[:ts] = Time.now.utc
        @db[:stat] = self.stat.members(with_scores: true).to_h
        @db[:attr] = self.attr.all
        Redis.new.pusblish "DEBUG.db", "#{@db}"
        return @db
      end
    else
      n = Time.now.utc
      return { ws: t, ts: t }
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
      ERB.new(s.gsub(',', '').gsub(".", "").gsub("!", '').downcase).result(binding).split('').each { |e| b = "   #{e}"; bb = b + (' ' * (8 - b.length)); @r.publish(@k, @kk.encrypt_block(bb)) }
    end
  end

  # Simple Web app
  class App < Sinatra::Base
	      HTML = %[<!DOCTYPE html>
<html>
  <head>
    <!-- basic style that will always work. -->
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
<!-- mobile first -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta charset="utf-8">
<title>nomadic</title>
<!-- INCLUDED LIBRARIES -->
<!-- All included libraries are hosted by third party cdn, verified by fingerprint - for safety. -->
<!-- jQuery: helpful object orientation for javascript. -->
<script src="https://code.jquery.com/jquery-3.5.1.min.js" integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin="anonymous"></script>
<!-- Google Material Icons: simple, understandable icons. -->
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<!-- pure javascript sha1 implementation -->
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
      <option value='card'>										     
      <option value='logs'>
      <option value='+'>
      <option value='-'>										     
    </datalist>
    <p id='t' class='i' style='width: 100%; text-align: center; margin: 0;'>
      <button type='button' class='material-icons do' id='welcome'>directions_walk</button> 
      <span style="width: 100%" id="ws">dialing in...</span>
      <button type='button' class='material-icons do' id='tags'>exposure</button>
    </p> 
    <fieldset style='height: 80vh; overflow-y: scroll;'>
      <legend id='input'>welcome</legend>
      <div id='output' style='height: 100%;'>#{WELCOME}</div>
    </fieldset>
    <p id='b' class='i' style='width: 100%; text-align: center; margin: 0; position: absolute; bottom: 0;'> 
      <button type='button' class='material-icons do' id='tasks' style='color: green;'>check_box_outline_blank</button>
      <input class='form' id='b_c' name='cmd' list="cmds" style='width: 50%;' placeholder='try me out...'>
      <button type='button' class='material-icons do' id='run' disabled>send</button>
    </p> 
  </form>
  <script>
var d = { init: true, id: "<%= rand_id %>", pipe: "<%= rand_pipe %>" };
var z;






										     

function btsearch() {
    let filters = [];
    
    let filterService = document.querySelector('#service').value;
    if (filterService.startsWith('0x')) { filterService = parseInt(filterService); }
    if (filterService) { filters.push({services: [filterService]}); }
    let filterName = document.querySelector('#name').value;
    if (filterName) { filters.push({name: filterName}); }
    let filterNamePrefix = document.querySelector('#namePrefix').value;
    if (filterNamePrefix) { filters.push({namePrefix: filterNamePrefix}); }
    let options = {};
    if (document.querySelector('#allDevices').checked) { options.acceptAllDevices = true;
						       } else { options.filters = filters; }
    console.log('Requesting Bluetooth Device...');
    console.log('with ' + JSON.stringify(options));
    navigator.bluetooth.requestDevice(options)
	.then(device => { console.log('> Name:             ' + device.name);
			  console,log('> Id:               ' + device.id);
			  console.log('> Connected:        ' + device.gatt.connected);
			})
	.catch(error => { console.log('Argh! ' + error); });
}
										     
										     
										     












										     

										     
var ws  = new WebSocket('wss://' + window.location.host + '?pipe=' + d.pipe );                                                 
ws.onopen = function() { message(d); console.log("WS: OPEN"); }                                                               
ws.onclose = function() { console.log("WS: CLOSE"); }                                                                         
ws.onmessage = function(m) { console.log("WS: IN", m); handle(JSON.parse(m.data)); }                                          
function message(o) { console.log( "WS: OUT", o);  ws.send(JSON.stringify(o)); } 

function handle(dd) {
        if ( dd.badauth ) {                                                                                                       
            localStorage.clear();                                                                                                 
            $("#t").hide();                                                                                                       
            $("#b").hide();                                                                                                       
            $('html').innerHTML = "<h1 style='padding: 25%; height: 100%; text-align: center;'><span style='border: thin outset black; border-radius: 10px;'><a href='" + window.location + "'>try again...</a></span></h1>";                                       
            // halt and catch fire!                                                                                               
        } else {
            d = dd;
            display();
        }
}     
 
function display() {
   console.log("display", d);
   if (d.ws) { $("#ws").text(d.ws); } else { $("#ws").text(t.ts); }
   if (d.title) { $("#input").html(d.input); }
   if (d.output) { $("#output").html(d.output); }                                                                        
   if ( $("#b").val() == '' && d.cmd ) { $("#b").val(d.cmd); } 
}							
			     
function getForm() {
    var ia = {};
    console.log("get", $("#form").serializeArray());
    $.map($('.form'), function(n, i) { ia[$(n).attr('name')] = $(n).val(); }); return ia;
}

function sendForm(th, p) {
    $("#run").css('color', 'blue');
    var dx = {};
    Object.assign(dx, d);
    if (p) {
      dx.user = localStorage.getItem("U");
      dx.pass = p;
    }
    dx.trigger = th;
    dx.form = getForm();
    console.log("send", dx);
    $.post('/', dx);
    resetUI();
}

function resetUI() {
    $("#tasks").css('color', 'green');
    $('#tasks').prop('disabled', false); 
    $("#run").css('color', 'black');
    $('#run').prop('disabled', true);
}

function cp(t) {
         $("#b_c").val(t);
         $("#b_c").val().select();
         document.execCommand("copy");
}

$(function() {                                                                                                              
    var zz = localStorage.getItem("U");										 
    if (zz == null || z == undefined) {
        $("#form").hide();
        $("#auth").show();
    }
    resetUI();
    $(document).on('submit', "form", function(ev) { ev.preventDefault(); });
    $(document).on('click', '#signin', function(ev) { 
        ev.preventDefault();
        localStorage.setItem("U", sha1($("#U").val()));
        sendForm("auth", sha1($("#Z").val()));
        $("#U").val("");
        $("#Z").val("");
        $("#auth").hide();                                                                                                        
        $("#form").show();
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
    $(document).on('click', '.do', function(ev) { 
	ev.preventDefault(); 
	sendForm($(this).attr('id'));
    });

});
									     </script>										     </body>
</html>
        ]
    
    def initialize()
      super()
      # user/tag handler
      @vm = Hash.new { |h,k| h[k] = K.new(k) }
      # demographic metric handler
      @metrics = Hash.new { |h,k| h[k] = Metric.new(k) }
    end
    helpers do
      
      ## ID STRUCTURE
      # NxCIIIIIIrrr
      def rand_id *a
        # always Nx0 for hubs. 0 signals interactive. node class
        # is determined by the third character and cannot be 0.
        a = ["#{PREFIX}0"];
        if FUNCTION != 'none' 
          if a[0]
            a << "#{'0' * (3 - a.length)}#{a[0]}"
          else
            a << "fff";
          end
        end
        4.times { a << rand(1..16).to_s(16) };
        return a.join('')
      end

      def rand_pipe
        a = []; 32.times { a << rand(16).to_s(16) }; return a.join('');
      end
    end
    
    configure do
      set :bind, '0.0.0.0'
      set :port, 8080
      set :server, 'thin'
      set :sockets, []
    end

    # capture demographic metrics
    before do
      @metrics[:referer].up request.referer
      @metrics[:agent].up request.user_agent
      @metrics[:route].up request.path_info
      Redis.new.publish "App.#{request.request_method}", "#{request.fullpath} #{params}"
    end
    
    # serve app route
    get('/') {
      if !request.websocket?
        # deliver app html if not websocket
        ERB.new(HTML).result(binding)
      else
        # proxy ws <-> redis
        @r = Redis.new
        request.websocket do |ws|
          ws.onopen {
            Process.detach( fork { @r.subscribe(params[:pipe]) { |on| on.message { |ch, m| ws.send(m); } } } )
            settings.sockets << ws
            ws.send(JSON.generate({ ws: "moving..." }))
          }
          ws.onmessage { |msg|
            j = JSON.parse(msg);
            r = @vm[j[:id]].eval(params)
            @r.publish(j[:pipe], JSON.generate(r))
          }
          ws.onclose { @r.unsubscribe(ch); settings.sockets.delete(ws) }
        end
      end
    }

    if FUNCTION != 'none'
      # display user/tag content.
      get('/:id') {
        case
        when FUNCTION != 'none' && Redis::Set.new("tags").include?(params[:id]) 
          @members = Redis::Set.new("group:#{params[:id]}").members
          @group = Redis::HashKey.new("tag:#{params[:id]}")
          ERB.new(TAG).result(binding)
        when FUNCTION != 'none' && @vm[params[:id]].md != nil 
          @vm[params[:id]].html
        else
          redirect '/'
        end
      }
    end

    # handle ajax json post
    post('/') {
      content_type "application/json"
      h = JSON.generate(@vm[params[:id]].eval(params))
      Redis.new.publish(params[:pipe], h)
      return h
    }

    # remember questionable traffic
    not_found do
      h = {
        method: request.request_method,
        host: request.host,
        port: request.port,
        path: request.path_info,
        referer: request.referer,
        agent: request.user_agent,
        params: params
      }
      t = Time.now.utc.to_i
      Redis::Set.new("404s") << t
      Redis::HashKey.new("404")[t] = JSON.generate(h)
      Redis.new.publish "404.#{t}", JSON.generate(h)
    end
  end

  # start app
  def self.begin
    @@HUB, @@MQTT = {}, {}
    Process.detach( fork { App.run! } )
  end
end

