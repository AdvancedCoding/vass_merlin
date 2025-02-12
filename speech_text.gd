extends MarginContainer

signal finished_displaying
@onready var label = $MarginContainer/Label
@onready var timer = $LetterDisplayTimer

var MAX_WIDTH = 256
var text = ""
var letter_index = 0
var letter_time = 0.03
var space_time = 0.06
var punctuation_time = 0.2
var original_pos: Vector2;
func _ready() -> void:
	visible = false
	original_pos = global_position;
	MAX_WIDTH = get_window().size.x
	#get_window().size = MAX_WIDTH
	SignalBus.merlin_speak.connect(display_text)
	#finished_displaying.connect(reset)
	
func display_text(ai_text:String):
	visible = true
	text = ai_text
	label.text = ai_text
	await resized
	custom_minimum_size.x = min(size.x,MAX_WIDTH)
	
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized #wait x
		await resized #wait y
		
	global_position.x -= size.x / 2
	global_position.y -= size.y + 24
	label.text = ""
	_display_letter()
	
func _display_letter():
	label.text += text[letter_index]
	
	letter_index +=1
	if letter_index >= text.length():
		finished_displaying.emit()
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
	await get_tree().create_timer(1).timeout
	queue_free()
	#global_position = orignal_pos;
	#label.text = "";
	
