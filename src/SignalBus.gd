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
