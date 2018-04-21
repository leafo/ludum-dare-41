extends KinematicBody2D

const SPEED = 200

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	var movement = Vector2(0,0)

	if Input.is_action_pressed("ui_left"): 
		movement.x -= 1

	if Input.is_action_pressed("ui_right"): 
		movement.x += 1

	if Input.is_action_pressed("ui_up"): 
		movement.y -= 1

	if Input.is_action_pressed("ui_down"): 
		movement.y += 1

	if movement.length_squared() != 0:
		movement = movement.normalized() * SPEED

	move_and_slide(movement)
