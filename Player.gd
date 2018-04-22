extends KinematicBody2D

const SPEED = 100
const FRICTION = 5
const ACCELERATION = 10
const EPSILON = 0.00001

var skating = false
var just_tapped = false
var holding_object = null

var facing = "left"

var velocity = Vector2()

var locked_on = {}

func _ready():
	pass

onready var puck = get_parent().get_node("Puck")

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
			movement.y -= 1

		if Input.is_action_pressed("ui_down"): 
			movement.y += 1

	if movement.x < 0:
		$Sprite.flip_h = false
		$LockOnArea.scale.x = 1
		facing = "left"

	if movement.x > 0:
		$Sprite.flip_h = true
		$LockOnArea.scale.x = -1
		facing = "right"

	if Input.is_action_just_pressed("ui_accept"):
		if holding_object:
			release_puck()
			shoot_puck()
		else:
			grab_puck()

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
	position_camera()
	find_targets()

func find_targets():
	if not holding_object:
		if not locked_on.empty():
			# remove the lock on
			for target in locked_on.keys():
				target.remove_lock_on()
				locked_on.erase(target)

		return

	var bodies = $LockOnArea.get_overlapping_bodies()

	var seen_items = {}

	for body in bodies:
		if not "Target" in body.get_groups():
			continue

		seen_items[body] = true

		if body.lock_on():
			locked_on[body] = true

	# remove things that are no longer locked on
	if not locked_on.empty():
		# remove the lock on
		for target in locked_on.keys():
			if seen_items.has(target):
				continue

			target.remove_lock_on()
			locked_on.erase(target)


func position_camera():
	var camera = $CameraTarget

	var offset = Vector2(0, 0)
	var count = 1

	# find all pucks in range
	for body in $PuckCameraZone.get_overlapping_bodies():
		if "Puck" in body.get_groups():
			var to_puck = body.position - position
			offset += to_puck
			count += 1

	offset = offset / count
	camera.position = offset


func release_puck():
	if not holding_object: 
		return

	holding_object.release()
	holding_object = null

func grab_puck():
	if not puck.within_range(self):
		return

	if holding_object:
		return

	if not puck.grab_by(self):
		return
	
	$SoundPickup.play()
	holding_object = puck

func shoot_puck():
	var distance = position.distance_to(puck.position)
	if distance < 30: 
		puck.shoot((puck.position - position).normalized())

func check_for_hits():
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		var object = collision.collider

		if "Puck" in object.get_groups():
			if not just_tapped:
				$SoundTap.play()
				just_tapped = true
				$SoundTap/Timeout.start()
			object.push(collision.normal * -100)

func get_hold_position():
	if facing == "left":
		return position + Vector2(-15, 0)
	else:
		return position + Vector2(15, 0)

func start_skating():
	skating = true
	$SkateSoundTimer.wait_time = 0.4
	$SkateSoundTimer/Animation.play("StartSkating")
	$SkateSoundTimer.start()

func _on_SkateSoundTimer_timeout():
	$SoundSkate.play()
	$SkateSoundTimer.start()

func _on_TapTimeout_timeout():
	just_tapped = false
