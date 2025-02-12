extends Node2D
@onready var sam:GDSAM= $GDSAM;
@onready var audio_player = $AudioStreamPlayer
@onready var animation:AnimatedSprite2D = $AnimatedSprite2D
@onready var merlin_speech_bubble = preload("res://speech_text.tscn")
var bubble;
var to: Vector2i

# https://docs.godotengine.org/en/stable/tutorials/export/changing_application_icon_for_windows.html
#App.ico
func _ready() -> void:
	animation.animation_finished.connect(_on_animation_finished)

	SignalBus.ai_response.connect(ai_speak)
	SignalBus.idle_timer_triggered.connect(idle)
	
	await  get_tree().create_timer(1.5).timeout #wait a moment that merlin can load in first
	ai_speak("Hello I am Merlin!")
	pass # Replace with function body.

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		move()
	if Input.is_action_just_pressed("right_click"):
		SignalBus.show_user_input_field.emit(true);
		pass
	pass

func ai_speak(sentence:String):
	create_merlin_speech_bubble()
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
	tween.tween_property(b_window, "position", to, 0.7)
	await tween.finished
	var landstr :String = "land"+dir.erase(0,3) 
	animation.play(landstr)
	
func idle():
	var r  = randi_range(1, 4)
	#print(r)
	if (r == 1):
		ai_speak("Hello are you there?")
	elif (r == 2):
		move()
	elif (r == 3):
		SignalBus.ask_ai.emit("Tell me a fun fact")
	elif (r == 4):
		ai_speak("Uploading user data...")
		

	pass
	
func create_merlin_speech_bubble():
	bubble = merlin_speech_bubble.instantiate() 
	bubble.finished_displaying.connect(bubble.reset)
	get_tree().root.add_child(bubble)
	
func _on_animation_finished():
	match animation.animation:
		"fly_right","fly_left":#https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#match
			tween_window_move(get_window(),to,animation.animation)
			ai_speak("woooo o")
		_:
			pass
