extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().get_root().set_transparent_background(true)
	
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
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _mouse():
	print("mouse")
