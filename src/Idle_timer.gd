extends Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_wait_time(10.0)
	self.set_autostart(true)
	SignalBus.reset_idle_timer.connect(_reset_timer)
	print("timer running")
	pass # Replace with function body.

#timer ran out, emit idle timer signal and set a new time 
func _on_idle_timer_timeout():
	SignalBus.idle_timer_triggered.emit()
	var new_wait_time = randf_range(10,30)
	self.set_wait_time(new_wait_time)
	print("trigger idle event, new time: ", new_wait_time)
	pass
	
#Resets timer back to its full wait time
func _reset_timer():
	self.start()
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
