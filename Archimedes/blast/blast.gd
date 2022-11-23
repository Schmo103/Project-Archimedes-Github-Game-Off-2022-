extends Node2D


func emit():
	get_node("CanvasLayer/Node2D").position = get_parent().position
	get_node("CanvasLayer/Node2D/Particles2D").emitting = true
