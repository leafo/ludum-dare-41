tool
extends Node2D

export var radius = 2 setget set_radius
export var color = Color("#47A44D") setget set_color

func _draw():
	draw_circle(Vector2(0,0), radius, color)

func set_color(c): 
	color = c
	update()

func set_radius(r):
	radius = r
	update()
