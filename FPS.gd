extends Label

onready var skate_timer = get_node("/root/Main/Sprites/Player/SkateSoundTimer")

func _process(delta): 
	text = "FPS: " + str(Engine.get_frames_per_second()) + ", Timer: " + str(skate_timer.wait_time)
