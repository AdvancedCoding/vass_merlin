extends Node2D
@onready var http_request = $HTTPRequest
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().get_root().set_transparent_background(true)
	print(self.get_window().transparent)
	SignalBus.ask_ai.connect(ask_AI)
	http_request.request_completed.connect(self._http_request_completed)
	#https://docs.godotengine.org/en/stable/classes/class_window.html#class-window --self.get_window()
	self.get_window().mouse_entered.connect(_mouse) #Gets Window from this instance
	self.get_window().transparent =true;
	
	#https://docs.godotengine.org/en/stable/classes/class_os.html
	var output = []
	#var exit_code = OS.execute("ls", ["-l", "/tmp"], output) 
	#print(output)
	#OS.execute(); #= true
	
	
	#https://docs.godotengine.org/en/stable/classes/class_displayserver.html#class-displayserver  
	var mouse_pos= DisplayServer.mouse_get_position()
	print(mouse_pos)
	
	#setup idle timer

	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#var r  = randi_range(1, 500)
	#if (r == 1):
	#	SignalBus.idle_timer_triggered.emit()
	pass

	

func _mouse():
	#SignalBus.ask_ai.emit("How to create a good meal")	
	print("mouse")

func ask_AI(input:String): #curl http://localhost:11434/api/generate -d '{"model": "deepseek-r1:1.5b","prompt": "Why is the sky blue?","stream": false}'
	SignalBus.reset_idle_timer.emit()
	var fields = {"model": "deepseek-r1:1.5b","prompt": input,"stream": false} #codegemma,deepseek-r1:1.5b
	var json = JSON.stringify(fields)
	var headers = ["Content-Type: application/json"]
	http_request.request("http://127.0.0.1:11434/api/generate", headers, HTTPClient.METHOD_POST, json)

func _http_request_completed(result: int, response_code: int, headers: PackedStringArray, body:PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		SignalBus.ai_response.emit("Sorry Merlin is not smart enough")
	else:
		var body_as_string = body.get_string_from_utf8() #bytes to string
		var x = JSON.parse_string(body_as_string)
		var response:String = x.response
		var parsed = response.replace("<think>\n\n</think>\n\n","");
		SignalBus.ai_response.emit(parsed)
		print(parsed)
		pass
