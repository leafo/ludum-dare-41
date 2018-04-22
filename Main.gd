extends Node

var GameOver = preload("res://GameOver.tscn")

func _on_Player_die_animation_finished():
	var game_over = GameOver.instance()
	find_node("UI").add_child(game_over)
