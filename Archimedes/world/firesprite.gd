extends KinematicBody2D


onready var timer = $NewSpawnerTimer
onready var spawn_time = 5

func spawner():
	for i in 10:
		timer.start(spawn_time)

func _ready():
	spawner()


func _on_NewSpawnerTimer_timeout():
	print("stopped")
	
