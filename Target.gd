extends KinematicBody2D

func take_hit(collision, object):
	var speed = object.velocity.length()
	if speed > 85:
		$AnimationPlayer.play("Hit")


