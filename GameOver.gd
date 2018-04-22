extends Control

export var score = 99 setget set_score

var animating = true

func _process(delta):
	if animating:
		return true
	
	if Input.is_action_just_pressed("ui_accept"):
		print("go back to title screen")

func _ready():
	$AppearAnimation.play("Appear")
	find_node("ThrobAnimation").play("Throb")

func set_score(s):
	score = s
	var score_node = find_node("Score")
	
	# setter is called before tree is initialized
	if score_node:
		score_node.text = "Score: %d" % score

func _on_Score_tree_entered():
	find_node("Score").text = "Score: %d" % score

func _on_AppearAnimation_animation_finished(anim_name):
	animating = false
