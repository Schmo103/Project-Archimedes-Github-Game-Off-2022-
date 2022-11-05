extends Node2D
#
#
#onready var timer = $fire_sprite_timer
#onready var spawn_time = 1
#onready var fire_sprite = load('res://firesprite.tscn')
#var spawnable = true
#var screen_x = OS.get_window_size().x
#var screen_y = OS.get_window_size().y
#var rand_x = randi() % screen_x
#var rand_y = randi() % screen_y
#
#
#func spawner():
#	if spawnable == true:
#		timer.start(spawn_time)
#	else:
#		timer.stop()
#
#func _ready():
#	spawner()
#	print(screen_x)
#	print(screen_y)
#
#func _process(delta):
#	pass
#
#func _on_fire_sprite_timer_timeout():
#	var instance = fire_sprite.instance()
#	add_child(instance)
#	instance.position = Vector2(rand_x,rand_y)
