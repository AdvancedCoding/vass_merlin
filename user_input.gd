extends LineEdit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.text_submitted.connect(_text_submit)
	SignalBus.show_user_input_field.connect(close_user_input)
	self.get_window().close_requested.connect(close_user_input)
	pass # Replace with function body.

func _text_submit(s:String):
	SignalBus.ask_ai.emit(s) #ask ai and clear text
	self.text = "";
func close_user_input(show:bool=false):
	if show:
		self.get_window().show()
	else:
		self.get_window().hide()
