extends "res://Target.gd"

const FRICTION = 5
const EPSILON = 0.00001

var velocity = Vector2()

func _process(delta):
	if velocity.length_squared() != 0:
		if velocity.length_squared() <= EPSILON:
			velocity = Vector2()
		else:
			velocity = velocity.linear_interpolate(Vector2(), delta * FRICTION)

	move_and_slide(velocity)

func take_hit(collision, object):
	print("enemy taking hit")
	$SoundHurt.play()
	var dir = (position - object.position).normalized()
	velocity += dir * 100
	.take_hit(collision, object)

