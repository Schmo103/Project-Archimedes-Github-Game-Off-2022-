extends Node

var world = preload("res://world.tscn")
var menu = preload("res://menu.tscn")
var current_scene = "menu"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.

func to_world():
	get_tree().paused = false
	var w = world.instance()
	add_child(w)
	get_node(current_scene).queue_free()
	current_scene = w.name
	
func to_menu():
	get_tree().paused = false
	var m = menu.instance()
	add_child(m)
	get_node(current_scene).queue_free()
	current_scene = m.name
	
	

func _ready():
	pass # Replace with function body.


