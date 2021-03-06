extends KinematicBody2D

const SPEED = 100
const FRICTION = 5
const ACCELERATION = 10
const EPSILON = 0.00001

onready var combo_counter = $"/root/Main/ComboCounter"

signal health_update(health)
signal die()
signal die_animation_finished()

var health = 100
var skating = false
var just_tapped = false
var holding_object = null
var stunned = false
var dead = false

var facing = "left"

var velocity = Vector2()

var locked_on = {}

func _ready():
	emit_signal("health_update", health)

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
	if dead: 
		return


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
		if not stunned:
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
				remove_lock_on(target)

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

			remove_lock_on(target)

func remove_lock_on(target):
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

func lose_puck():
	$SoundDrop.play()
	release_puck()

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

	combo_counter.end_combo()
	$SoundPickup.play()
	holding_object = puck

func shoot_puck():
	# you can only shoot if it's it's near by 
	if puck.within_range(self):
		var targets = sorted_targets()

		if targets:
			puck.shoot_targets(targets)
		else:
			var direction = (puck.position - position).normalized()
			puck.shoot(direction)

func sorted_targets():
	if locked_on.empty():
		return null

	var closest = locked_on.keys()
	closest.sort_custom(self, "sort_targets")
	return closest

func check_for_hits():
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		var object = collision.collider
		var groups = object.get_groups()

		if "Enemy" in groups:
			take_hit(collision, object)

		if "Puck" in groups:
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

# sort targets by distance to self
func sort_targets(a, b):
	var a_dist = (a.position - position).length_squared()
	var b_dist = (b.position - position).length_squared()

	if a_dist < b_dist:
		return true

	return false

func take_damage(amount):
	health = max(0, health - amount)
	emit_signal("health_update", health)

	if health == 0:
		dead = true
		release_puck()
		$DieAnimation.play("Die")
		emit_signal("die")
		set_collision_layer_bit(1, false)

		if skating:
			skating = false
			$SkateSoundTimer.stop()

		return true

# hit by an enemy
func take_hit(collision, object):
	if stunned:
		return

	print("Player takes hit")
	take_damage(25)

	if dead:
		$SoundDie.play()
	else:
		$SoundHurt.play()

	stunned = true
	$StunTimer.start()
	$CameraShake.play("Shake")
	$HitAnimation.play("Hit")
	velocity = (position - object.position).normalized() * 100

func _on_SkateSoundTimer_timeout():
	$SoundSkate.play()
	$SkateSoundTimer.start()

func _on_TapTimeout_timeout():
	just_tapped = false

func _on_StunTimer_timeout():
	stunned = false

func _on_DieAnimation_animation_finished(anim_name):
	emit_signal("die_animation_finished")
