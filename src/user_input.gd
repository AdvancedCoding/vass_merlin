extends LineEdit


func _ready() -> void:
	caret_blink = true
	text_changed.connect(_on_text_changed)
	self.get_window().hide() #hide on start
	self.text_submitted.connect(_text_submit)
	SignalBus.show_user_input_field.connect(close_user_input)
	self.get_window().close_requested.connect(close_user_input)
	pass # Replace with function body.

func _text_submit(s:String):

		if s.contains("/AskAI"):
			SignalBus.ask_ai.emit(s) #ask ai and clear text
		if s.contains("/8Ball"):
			SignalBus.ask_magic8ball.emit()
		self.text = "";
func close_user_input(show:bool=false):
	if show:
		self.get_window().show()
	else:
		self.get_window().hide()

# Array of strings for autocomplete
var autocomplete_options = ["/8Ball", "/Test","/AskAI"]
#var popup:PopupMenu;
func _on_text_changed(new_text: String):
	#get_popup().clear()
	if new_text.begins_with("/"):
		var suggestions = get_matching_suggestions(new_text)
		if suggestions.size() > 0:
			for suggestion:String in suggestions:
				print(suggestion)
				#popup.add_item(suggestion)
			#update_popup_position()
			#popup.show()
		#else:
			#get_popup().hide()
	#else:
		#get_popup().hide()
	#grab_focus()
func get_matching_suggestions(input: String) -> Array:
	var matches = []
	for option in autocomplete_options:
		if input.to_lower() in option.to_lower():
			matches.append(option)
	return matches
func _process(delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_TAB):
		var matched:Array = get_matching_suggestions(text);
		if(matched.size()>0): #else it will crash
			text = matched.pop_front()
			caret_column = text.length()
		
#func get_popup() -> PopupMenu:
	#if not has_node("AutocompletePopup"):
		#popup = PopupMenu.new()
		#popup.name = "AutocompletePopup"
		#add_child(popup)
		#popup.index_pressed.connect(_on_popup_item_clicked) # Updated for Godot 4
	#return get_node("AutocompletePopup")
#func _on_popup_item_clicked(index: int):
	#text = get_popup().get_item_text(index)
	#get_popup().hide()
	#caret_column = text.length()
#func update_popup_position():
	#var pos = get_window().position
	#popup.position = Vector2i(pos.x, pos.y + size.y)
	#popup.min_size.x = size.x
