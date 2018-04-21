extends KinematicBody2D

const SPEED = 100
const FRICTION = 5
const ACCELERATION = 10
const EPSILON = 0.00001

var velocity = Vector2()

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
		shoot_puck()

	if movement.length_squared() != 0:
		movement = movement.normalized() * SPEED
		velocity = velocity.linear_interpolate(movement, delta * ACCELERATION)
	else:
		var ls = velocity.length_squared() 

		if ls > 0:
			if ls < EPSILON:
				velocity = Vector2()
			else:
				velocity = velocity.linear_interpolate(movement, delta * FRICTION)

	move_and_slide(velocity)
	check_for_hits()

func shoot_puck():
	var puck = get_parent().get_node("Puck")
	var distance = position.distance_to(puck.position)
	if distance < 30: 
		puck.push((puck.position - position).normalized() * 200)

func check_for_hits():
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		var object = collision.collider

		if "Puck" in object.get_groups():
			print("Hit puck")
			object.push(collision.get_normal() * -100)

