extends KinematicBody2D

const MAX_SPEED = 200
const FRICTION = 1.5
const EPSILON = 0.00001
const SHOOT_SPEED = 300

var velocity = Vector2()

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
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

func on_hit(): 
	$SoundHit.play()
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

