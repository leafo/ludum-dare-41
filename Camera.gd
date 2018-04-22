extends Camera2D

export var shake_amount = 0.0
export var shake_speed = 1.0

var elapsed = 0

func _process(delta):
	if shake_amount > 0:
		elapsed += delta * shake_speed * 10
		offset = Vector2(
			shake_amount * sin(1 + elapsed),
			shake_amount * sin(1.4 + elapsed * 1.2)
		)
	