@icon("res://Assets/Mine/UI.svg")
extends Label

func _process(delta):
	var fps = Engine.get_frames_per_second()
	text = "FPS: "+str(fps)
