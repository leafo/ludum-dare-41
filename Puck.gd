extends KinematicBody2D

const SPEED = 200
const EPSILON = 0.00001

var movement = Vector2()

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	# decay movement
	if movement.length_squared() != 0:
		if movement.length_squared() <= EPSILON:
			movement = Vector2()
		else:
			movement = movement.linear_interpolate(Vector2(), delta / 0.1)

	move_and_slide(movement)

func push(direction):
	movement += direction