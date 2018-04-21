extends KinematicBody2D

const SPEED = 200

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	var movement = Vector2(0,0)

	if Input.is_action_pressed("ui_left"): 
		$Sprite.flip_h = false
		movement.x -= 1

	if Input.is_action_pressed("ui_right"): 
		$Sprite.flip_h = true
		movement.x += 1

	if Input.is_action_pressed("ui_up"): 
		movement.y -= 1

	if Input.is_action_pressed("ui_down"): 
		movement.y += 1

	if Input.is_action_just_pressed("ui_accept"):
		var puck = get_parent().get_node("Puck")
		print("shoot", puck)

	if movement.length_squared() != 0:
		movement = movement.normalized() * SPEED

	move_and_slide(movement)
	check_for_hits()

func check_for_hits():
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		var object = collision.collider

		if "Puck" in object.get_groups():
			print("Hit puck")
			object.push(collision.get_normal() * -100)

