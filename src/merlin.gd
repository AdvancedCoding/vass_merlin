extends Node2D
@onready var sam:GDSAM= $GDSAM;
@onready var audio_player = $AudioStreamPlayer
@onready var animation:AnimatedSprite2D = $AnimatedSprite2D
@onready var merlin_speech_bubble = preload("res://src/speech_text.tscn")
var to: Vector2i
@onready var merlin =$"."
@onready var joke_keyvalues = load_from_file();
@onready var magic_8ballresponses:Array = ["It is certain","It is decidedly so","Without a doubt","Yes definitely","You may rely on it","As I see it, yes","Most likely","Outlook good","Yes","Signs point to yes","Reply hazy, try again","Ask again later","Better not tell you now","Cannot predict now","Concentrate and ask again","Don't count on it","My reply is no","My sources say no","Outlook not so good","Very doubtful"]
var WINDOW_SIZE:Vector2
# https://docs.godotengine.org/en/stable/tutorials/export/changing_application_icon_for_windows.html
#App.ico
func _ready() -> void:
	
	#print(x)
	WINDOW_SIZE = get_window().size #Set initialsize to a var
	#get_window().mouse_passthrough = true; #this can be used ?
	#get_window().borderless = false #set this to true if you want to debug
	get_window().size = Vector2(140,140)
	animation.position = Vector2(0,0) #
	animation.animation_finished.connect(_on_animation_finished)
	SignalBus.ai_response.connect(ai_speak)
	SignalBus.idle_timer_triggered.connect(idle)
	SignalBus.resize.connect(resize_merlin_window)
	SignalBus.ask_magic8ball.connect(magic8ball)
	await  get_tree().create_timer(1.5).timeout #wait a moment that merlin can load in first
	animation.play("hand_wave")
	ai_speak("Hello I am Merlin!")
	await  get_tree().create_timer(2).timeout
	merlin_greetings();
	await  get_tree().create_timer(4.5).timeout
	
	#var test = "chromium-browser"
	#SignalBus.kill_proc(test);
	#SignalBus.send_notification.emit("Merlin says:", "iam terminating "+test);
	


	await  get_tree().create_timer(1.5).timeout
	#SignalBus.spawn_proc.emit("firefox", ["-private-window", "'https://www.google.com/search?q=youtube'"])
	#await  get_tree().create_timer(1.5).timeout
	#ai_speak(random_joke())
	

func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("click"):
	#	move()
	if Input.is_action_just_pressed("right_click"):
		SignalBus.show_user_input_field.emit(true);
		pass
	pass




#TODO: IMPLEMENT QUEUE, with functions "ADD TO", AND "CLEAR". Queue must loop and contain breaks
func ai_speak(sentence:String):
	create_merlin_speech_bubble()
	SignalBus.resize.emit(SignalBus.MERLIN_SIZES.SPEECH)
	SignalBus.merlin_speak.emit(sentence)
	sam.speak(audio_player,sentence)

func move():
		var rand = RandomNumberGenerator.new()
		var x = rand.randi_range(128, 3200)
		var y = rand.randi_range(128, 1000)
		to= Vector2i(x, y)
		if(to.x<get_window().position.x):
			animation.play("fly_left")	
		else:
			animation.play("fly_right")
		#get_window().position = to	
func tween_window_move(b_window,to:Vector2i,dir:String):
	var tween = get_tree().create_tween()
	tween.step_finished.connect(step)
	tween.tween_property(b_window, "position", to, 0.7)
	await tween.finished
	var landstr :String = "land"+dir.erase(0,3) 
	animation.play(landstr)
func step(idx:int):
	SignalBus.merlin_moved.emit()
func idle():
	var r  = randi_range(1, 5)
	match r:
		1:
			ai_speak("Hello are you there?")
		2:
			move()
		3:
			pass
			#SignalBus.ask_ai.emit("Tell me a fun fact")
		4:
			ai_speak("Uploading user data...")
		5:
			ai_speak(random_joke())
	pass
func merlin_greetings():
	var r  = randi_range(1, 2)
	match r:
		1:
			ai_speak(merlin_os_greetings())
		2:
			ai_speak("What is your name?")
		3:
			pass
	pass
	
func resize_merlin_window(size:SignalBus.MERLIN_SIZES):
	pass
	#if(size==SignalBus.MERLIN_SIZES.DEFAULT):
		#get_window().size = WINDOW_SIZE
		##get_window().content_scale_size = WINDOW_SIZE
	#else:
		#get_window().size = Vector2(800,256)
		##get_window().content_scale_size = Vector2(800,256)
func create_merlin_speech_bubble():
	var window_bubble = merlin_speech_bubble.instantiate()
	var bubble = window_bubble.find_child("text_box")
	get_tree().root.add_child(window_bubble)
	bubble.set_merlin_instance(merlin)
	print("%v merlin window pos" % [get_window().position])
	
func _on_animation_finished():
	match animation.animation:
		"fly_right","fly_left":#https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#match
			tween_window_move(get_window(),to,animation.animation)
			ai_speak("woooo.")
		_:
			pass

func random_joke()->String:
	return joke_keyvalues[randi_range(0, 100000)]
func load_from_file():
	var file = FileAccess.open("res://data/jokes.txt", FileAccess.READ) #do not open jokes.txt in godot it will break your pc
	var content = file.get_as_text()
	var jokes = parse_csv_data(content)
	return jokes
func parse_csv_data(csv_data):
	var result = {}
	var lines = csv_data.split("\n")
	for line in lines:
		var parts = line.split(",", false, 1)
		if parts.size() == 2:
			var key = int(parts[0].strip_edges())  # Convert to integer
			var value = parts[1].strip_edges()     # Get the value
			result[key] = value
	return result

func magic8ball()->void:
	ai_speak( magic_8ballresponses[randi_range(0, magic_8ballresponses.size()-1)])
	
func merlin_os_greetings()->String:
	match OS.get_name():
		"Windows":
			return "I see you are using spyware called windows, then iam a perfect buddy for you"
		"macOS":
			return "Welcome to macOS!"
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			return "I see that I'm running on penguin, how does that even work!?"
		"Android":
			return "Android I see you are a robot..."
		"iOS":
			return "Epple"
		"Web":
			return "Everything is made for spiders smh.."
	return ""
	
	
