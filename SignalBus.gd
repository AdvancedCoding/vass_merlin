extends Node

signal show_user_input_field(show:bool)
signal ask_ai(question:String)
signal ai_response(answer:String)
signal merlin_speak(paragraph:String)

signal idle_timer_triggered()
signal reset_idle_timer()
