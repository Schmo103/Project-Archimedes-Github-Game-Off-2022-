extends Node2D


#script for menu
func _on_Button_pressed():
	get_tree().change_scene("res://world.tscn")
func _ready():
	get_tree().paused = false

