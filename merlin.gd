extends Node2D
@onready var sam:GDSAM= $GDSAM;
@onready var audio_player = $AudioStreamPlayer
@onready var animation:AnimatedSprite2D = $AnimatedSprite2D
var to: Vector2i

# https://docs.godotengine.org/en/stable/tutorials/export/changing_application_icon_for_windows.html
#App.ico
func _ready() -> void:
	animation.animation_finished.connect(_on_animation_finished)
	sam.speak(audio_player,"Hello I am Merlin")
	
	pass # Replace with function body.

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		move()
	pass
	
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
	
func _on_animation_finished():
	match animation.animation:
		"fly_right","fly_left":#https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#match
			tween_window_move(get_window(),to,animation.animation)
			sam.speak(audio_player,"wooooo")
		_:
			pass
