extends Node2D
@onready var http_request = $HTTPRequest
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().get_root().set_transparent_background(true)
	#print(self.get_window().transparent)
	#get_window().size = Vector2(1000,1000)
	SignalBus.ask_ai.connect(ask_AI)
	SignalBus.send_notification.connect(send_notification)
	SignalBus.spawn_proc.connect(spawn_proc)
	SignalBus.kill_proc.connect(kill_proc)
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
	var fields = {"model": "codegemma","prompt": input,"stream": false} #codegemma,deepseek-r1:1.5b
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

#Shows a notification "toast"
func send_notification(title:String, message:String)->void:
	var app_name = ProjectSettings.get_setting("application/config/name")
	if app_name.is_empty():
		app_name = "Unnamed Project"
	if OS.has_feature("macos") and not OS.is_sandboxed():
		# Note that this will not work if the project is exported in sandbox mode
		# (e.g. for the Mac App Store).
		OS.execute("osascript", [
				"-e",
				'display notification \\"%s\\" with title \\"%s\\" subtitle \\"%s\\"' % [
					message,
					app_name,
					title,
				]
			])
	elif OS.has_feature("linuxbsd"):
		OS.execute("notify-send", ["--app-name", app_name, title, message])
		
		
func spawn_proc(proc:String,args=[])->void:
	print(proc)
	var joined_args = " ".join(args)
	await  get_tree().create_timer(0.5).timeout
	var exit_code = OS.execute_with_pipe("bash", [
			"-c", 
			proc+" "+joined_args
		]);
func kill_proc(process_name:String):
	var pids =get_pid_by_name(process_name,true)
	if (pids.size() == 0): return;
	for pid in pids:
		OS.kill(pid);
	#print(get_pid_by_name(process_name,true))

# ------------ EXTENSION FUNCTIONS FOR OS SYS CALLS ETC -----------------------
func get_pid_by_name(process_name: String,is_like:bool=true) -> Array[int]:
	var pids: Array[int] = []
	var output: Array = []
	var p_name = process_name.to_lower();
	var os = OS.get_name();
	print(os)
	if os == "Windows":
		# tasklist /FI "IMAGENAME eq example.exe"
		var exit_code = OS.execute("tasklist", ["/FI", "IMAGENAME eq " + process_name, "/FO", "CSV", "/NH"], output, true)
		if exit_code != 0:
			return pids
		for line in output:
			if line.strip_edges().is_empty():
				continue
			var parts = line.split('","')
			if parts.size() > 1:
				var name = parts[0].strip_edges().replace('"', '')
				if name.to_lower() == p_name or is_like and name.to_lower().contains(p_name):
					var pid_str = parts[1].strip_edges().replace('"', '')
					pids.append(int(pid_str))
	elif os in ["Linux", "FreeBSD", "NetBSD", "OpenBSD", "macOS"]:
		var exit_code = OS.execute("bash", [
			"-c", 
			'ps -eo pid,comm --no-headers | grep -i "' + process_name + '" | awk \'{print $1}\''
		], output, true)
		
		if exit_code != 0 or output.size()<1:
			return pids
		for line in output[0].split("\n"):
			line = line.strip_edges()
			if not line.is_empty():
				pids.append(int(line))
	else:
		push_warning("Unsupported platform for get_pid_by_name")
	return pids
# ------------END EXTENSION FUNCTIONS FOR OS SYS CALLS ETC -----------------------
