extends KinematicBody2D

const SPEED = 100
const FRICTION = 5
const ACCELERATION = 10
const EPSILON = 0.00001

var skating = false

var velocity = Vector2()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func deadzone_normalize(input, min_len=0.2, max_len=0.95):
	var l = input.length()
	if l > max_len:
		return input.normalized()

	if l < min_len:
		return Vector2()

	var sc = (l - min_len) / (max_len - min_len)
	return input.normalized() * sc

func _process(delta):
	var have_joystick = false
	var movement = Vector2(0,0)

	var joy_movement = Vector2(Input.get_joy_axis(0, JOY_AXIS_0), Input.get_joy_axis(0, JOY_AXIS_1))

	if joy_movement.length_squared() > 0:
		joy_movement = deadzone_normalize(joy_movement)
		if joy_movement.length_squared() > 0:
			movement = joy_movement
			have_joystick = true

	if not have_joystick: 
		if Input.is_action_pressed("ui_left"): 
			movement.x -= 1

		if Input.is_action_pressed("ui_right"): 
			movement.x += 1

		if Input.is_action_pressed("ui_up"): 
			movement.y -= 165

		if Input.is_action_pressed("ui_down"): 
			movement.y += 1

	if movement.x < 0:
		$Sprite.flip_h = false

	if movement.x > 0:
		$Sprite.flip_h = true

	if Input.is_action_just_pressed("ui_accept"):
		shoot_puck()

	if movement.length_squared() != 0:
		movement = movement.normalized() * SPEED
		velocity = velocity.linear_interpolate(movement, delta * ACCELERATION)

		if not skating:
			start_skating()
	else:
		if skating:
			skating = false
			$SkateSoundTimer.stop()

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
		puck.on_hit()
		puck.push((puck.position - position).normalized() * 300)

func check_for_hits():
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		var object = collision.collider

		if "Puck" in object.get_groups():
			object.push(collision.normal * -100)

func start_skating():
	print("start skating")
	skating = true
	$SkateSoundTimer.wait_time = 0.4
	$SkateSoundTimer/Animation.play("StartSkating")
	$SkateSoundTimer.start()

func _on_SkateSoundTimer_timeout():
	print("timer timed out......")
	$SoundSkate.play()
	$SkateSoundTimer.start()

