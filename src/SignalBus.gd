extends Node


signal show_user_input_field(show:bool)
signal ask_ai(question:String)
signal ai_response(answer:String)
signal ask_magic8ball(question:String)
signal merlin_speak(paragraph:String)
signal merlin_moved() #add merlin ref?

signal reset_speech_bubble()

signal idle_timer_triggered()
signal reset_idle_timer()


enum MERLIN_SIZES {  
	DEFAULT,      
	SPEECH,  
} 
signal resize(SIZE: MERLIN_SIZES)


#OS functions called from anywhere implemented in world.gd
#Prefix??? OS.send?
signal send_notification(title:String, message:String)

#Invokes bash or equivilant to spawn a background process which is not dependant of merlin
signal spawn_proc(proc:String,args:PackedStringArray)
#Kills a process by name
signal kill_proc(proc:String)
