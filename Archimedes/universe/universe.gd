extends Node

var world = preload("res://world.tscn")
var menu = preload("res://menu.tscn")
var current_scene = "menu"

#variables passed between scenes
var owens_way = true
var lava_on = false
var spawning = true
var score : int = 0
var high_score : int = 0

func to_world():
	get_tree().set_pause(false)
	var w = world.instance()
	w.lava_on = lava_on
	w.owens_way = owens_way
	w.spawning = spawning
	add_child(w)
	get_node(current_scene).queue_free()
	current_scene = w.name
	
func to_menu():
	get_tree().set_pause(false)
	score = get_node(current_scene).fscore
	if score > high_score:
		high_score = score
	prints("score:", str(score), "high:", str(high_score))
	var m = menu.instance()
	m.owens = owens_way
	m.lava_on = lava_on
	m.spawning = spawning
	m.hs = high_score
	add_child(m)
	get_node(current_scene).queue_free()
	current_scene = m.name
	
	

func _ready():
	pass # Replace with function body.


