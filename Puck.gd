extends KinematicBody2D

const MAX_SPEED = 200
const FRICTION = 1.5
const EPSILON = 0.00001
const SHOOT_SPEED = 500

var velocity = Vector2()

var just_hit = false

var held_by = null

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	if held_by: 
		var target_pos = position.linear_interpolate(held_by.get_hold_position(), min(1, delta * 25))
		move_and_slide((target_pos - position) / delta)
		return

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

func grab_by(obj):
	if held_by:
		return false

	held_by = obj
	# no collision
	set_collision_layer_bit(0, false)
	set_collision_mask_bit(0, false)
	return true
	
func release():
	held_by = null

	set_collision_layer_bit(0, true)
	set_collision_mask_bit(0, true)

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


func _on_Timeout_timeout():
	just_hit = false
