extends MarginContainer

#signal finished_displaying
@onready var label = $MarginContainer/Label
@onready var timer = $LetterDisplayTimer

var MAX_WIDTH = 256
var text = ""
var letter_index = 0
var letter_time = 0.03
var space_time = 0.06
var punctuation_time = 0.2
var bubble_has_value = false
var MERLIN_WINDOW = Object
#var original_pos: Vector2;
func _ready() -> void:
	SignalBus.reset_speech_bubble.connect(reset)
	visible = false
	get_window().position = Vector2(0,0)
	get_window().size = Vector2(500,600)
	#get_tree().get_instance_id()

	var x = get_tree().get_nodes_in_group("world")
	#original_pos = global_position;
	MAX_WIDTH = get_window().size.x
	global_position.y = 60;
	#get_window().size = MAX_WIDTH
	SignalBus.merlin_speak.connect(display_text)
	
func display_text(ai_text:String):
	if bubble_has_value == false: #stops listening after gets first signal because this is an instance class
		bubble_has_value =true;
		visible = true
		text = ai_text
		label.text = ai_text
		#await resized
		custom_minimum_size.x = min(size.x,MAX_WIDTH)
		
		
		#if size.x > MAX_WIDTH:
		#	label.autowrap_mode = TextServer.AUTOWRAP_WORD
		#	await resized #wait x
		#	await resized #wait y
		#	custom_minimum_size.y = size.y
		#	
		#global_position.x -= size.x / 2
		global_position.y -= size.y + 24
		label.text = ""
		_display_letter()

func _display_letter():
	label.text += text[letter_index]
	letter_index +=1
	if letter_index >= text.length():
		SignalBus.reset_speech_bubble.emit()
		#finished_displaying.emit()
		return
	match text[letter_index]:
		"!", ".", ",", "?":
			timer.start(punctuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)
func _on_letter_display_timer_timeout() -> void:
	_display_letter()
	pass # Replace with function body.

func reset():
	SignalBus.resize.emit(SignalBus.MERLIN_SIZES.DEFAULT)
	await get_tree().create_timer(1).timeout
	get_window().visible = false
	get_window().queue_free()
func set_merlin_instance(merlin:Node2D):
	#print("%v merlin ref window pos" % [merlin.get_window().position])
	#print("%v merlin textbox window pos" % [get_window().position])
	var m = merlin.get_window()
	var pos = Vector2(m.position.x-m.size.x/2,m.position.y-m.size.y/2)
	get_window().position = pos;
