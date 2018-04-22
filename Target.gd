extends KinematicBody2D

var LockOn = preload("res://LockOn.tscn")

var current_lock_on = null
var stunned = false

func lock_on():
	if current_lock_on:
		return false

	current_lock_on = LockOn.instance()
	add_child(current_lock_on)
	return true

func remove_lock_on():
	current_lock_on.queue_free()
	current_lock_on = null

func take_hit(collision, object):
	stun()
	var speed = object.velocity.length()
	if speed > 85:
		$HitAnimation.play("Hit")

func stun():
	if stunned:
		return
		
	stunned = true
	set_collision_layer_bit(4, false)
	set_collision_layer_bit(5, true)
	$StunTimer.start()

func _on_StunTimer_timeout():
	stunned = false
	set_collision_layer_bit(5, false)
	set_collision_layer_bit(4, true)
