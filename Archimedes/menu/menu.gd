extends Node2D


#script for menu
func _on_Button_pressed():
	if get_parent() == get_node("/root"):
		get_tree().change_scene("res://world.tscn")
	else:
		get_parent().to_world()

func _ready():
	get_tree().paused = false

