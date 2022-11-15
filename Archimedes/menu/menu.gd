extends Node2D

var owens = true
var lava_on = true
var spawning = true
#script for menu
func _on_Button_pressed():
	if get_parent() == get_node("/root"):
		get_tree().change_scene("res://world.tscn")
	else:
		update_parent()
		get_parent().to_world()
		
func _ready():
	update_buttons()

func update_parent():
	if get_parent() != get_node("/root"):
		get_parent().owens_way = owens
		get_parent().lava_on = lava_on
		get_parent().spawning = spawning


func update_buttons():
	if lava_on:
		$lava.text = "Turn lava off"
	else:
		$lava.text = "Turn lava on"
	if owens:
		$owens.text = "Turn owens way off"
	else:
		$owens.text = "Turn owens way on"
	if spawning:
		$spawning.text = "Turn explosions off"
	else:
		$spawning.text = "Turn explosions on"


func _on_lava_pressed():
	if lava_on:
		$lava.text = "Turn lava on"
		lava_on = false
	else:
		$lava.text = "Turn lava off"
		lava_on = true

func _on_owens_pressed():
	if owens:
		$owens.text = "Turn owens way on"
		owens = false
	else:
		$owens.text = "Turn owens way off"
		owens = true


func _on_spawning_pressed():
	if spawning:
		$spawning.text = "Turn explosions on"
		spawning = false
	else:
		$spawning.text = "Turn explosions off"
		spawning = true
