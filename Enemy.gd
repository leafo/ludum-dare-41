extends "res://Target.gd"

const FRICTION = 5
const EPSILON = 0.00001

var velocity = Vector2()

export var health = 4 setget set_health
var dead = false

func _process(delta):
	if velocity.length_squared() != 0:
		if velocity.length_squared() <= EPSILON:
			velocity = Vector2()
		else:
			velocity = velocity.linear_interpolate(Vector2(), delta * FRICTION)

	move_and_slide(velocity)

func set_health(h):
	health = max(0, h)
	if health == 0:
		dead = true

func take_hit(collision, object):
	if dead:
		return

	var speed = object.velocity.length()

	if speed < damage_speed:
		# puck moving too slow
		return

	$SoundHurt.play()
	var dir = (position - object.position).normalized()
	velocity += dir * 100
	set_health(health - 1)

	if dead:
		$DieAnimation.play("Die")
		set_collision_layer_bit(4, false)
		set_collision_mask_bit(2, false)
		remove_from_group("Target")
		return

	.take_hit(collision, object)

func _on_DieAnimation_animation_finished(anim_name):
	queue_free()


func _on_ActionTimer_timeout():
	# see if they can shoot at player
	var bodies = $ShootRange.get_overlapping_bodies()
	for body in bodies:
		if not "Player" in body.get_groups():
			continue
			
		print("Player in range", body)
	
