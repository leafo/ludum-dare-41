extends KinematicBody2D

const MAX_SPEED = 300
const FRICTION = 1.5
const EPSILON = 0.00001
const SHOOT_SPEED = 300

var velocity = Vector2()

var just_hit = false
var remaining_targets = null

var held_by = null

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	if remaining_targets:
		$Label.text = "Targets: " + str(remaining_targets.size())
	else:
		$Label.text = "Targets: 0"

	if held_by: 
		var hold_position = held_by.get_hold_position()

		if within_range(held_by):
			var target_pos = position.linear_interpolate(hold_position, min(1, delta * 25))
			move_and_slide((target_pos - position) / delta)
			return

		# out of range, drop it
		print("puck out of range", (hold_position - position).length())
		held_by.lose_puck()
		velocity = Vector2()

	# decay velocity
	if velocity.length_squared() != 0:
		if velocity.length_squared() <= EPSILON:
			velocity = Vector2()
		else:
			velocity = velocity.linear_interpolate(Vector2(), delta * FRICTION)

	move_and_slide(velocity)
	check_for_hits()

func push(direction):
	velocity += direction
	velocity = velocity.clamped(MAX_SPEED)

func shoot(direction): 
	push(direction * SHOOT_SPEED)
	on_hit()
	if rand_range(0,1) < 0.5:
		$BounceAnimation.play("Bounce")
	else:
		$BounceAnimation.play("BounceFlip")

func clear_targets():
	remaining_targets = null

# go through targets hitting them
func shoot_targets(targets):
	remaining_targets = targets.duplicate()
	shoot(pop_next_target())

# returns direction to next target
func pop_next_target():
	if not remaining_targets:
		return

	var target = remaining_targets.pop_front()

	if remaining_targets.size() == 0:
		clear_targets()

	return (target.position - position).normalized()

func grab_by(obj):
	if held_by:
		return false

	clear_targets()

	held_by = obj
	velocity = Vector2()

	# move the layer to held puck
	set_collision_layer_bit(2, false)
	set_collision_layer_bit(3, true)
	return true
	
func release():
	held_by = null
	set_collision_layer_bit(3, false)
	set_collision_layer_bit(2, true)

func on_hit(): 
	if not just_hit:
		just_hit = true
		$SoundHit.play()
		$SoundHit/Timeout.start()

	if velocity.length() > 95:
		$HitAnimation.play("HitHoriz")

func check_for_hits():
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		var object = collision.collider

		if "PuckBounce" in object.get_groups():
			velocity = (-velocity).reflect(collision.normal)
			on_hit()

			if "Target" in object.get_groups():
				object.take_hit(collision, self)
				if remaining_targets:
					var angle = pop_next_target()
					$DirectionVector.rotation_degrees = angle.angle() / PI * 180
					velocity = angle * velocity.length() * 1.2
			else:
				clear_targets()

func within_range(body):
	# return $HoldRadius.overlaps_body(body)
	return true

func _on_Timeout_timeout():
	just_hit = false
