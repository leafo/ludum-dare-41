extends KinematicBody2D

var LockOn = preload("res://LockOn.tscn")

var current_lock_on = null

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
	var speed = object.velocity.length()
	if speed > 85:
		$AnimationPlayer.play("Hit")


