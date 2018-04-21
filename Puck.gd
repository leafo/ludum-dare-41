extends KinematicBody2D

const MAX_SPEED = 200
const FRICTION = 1.5
const EPSILON = 0.00001

var velocity = Vector2()

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	# decay velocity
	if velocity.length_squared() != 0:
		if velocity.length_squared() <= EPSILON:
			velocity = Vector2()
		else:
			velocity = velocity.linear_interpolate(Vector2(), delta * FRICTION)

	move_and_slide(velocity)

func push(direction):
	velocity += direction
	velocity = velocity.clamped(MAX_SPEED)
