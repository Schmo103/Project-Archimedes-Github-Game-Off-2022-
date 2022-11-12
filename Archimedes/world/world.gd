extends Node2D

var terrain = "/root/World/terrain"
var lava = "/root/World/Lava"


onready var timer = $fire_sprite_timer
onready var spawn_time = 7
onready var fire_sprite = load('res://firesprite.tscn')
var spawnable = true
var screen_x = OS.get_window_size().x
var screen_y = OS.get_window_size().y

onready var rand_x
onready var rand_y 

signal firesprite_hits_player 


onready var bkgd = $background
onready var b_offset = Vector2(557, 405)
onready var note = $death_note
var n_offest = Vector2(-174, -104)
onready var butn = $menu
var m_offset = Vector2(-103, 35)
onready var fog = get_node("wavy shader")

func spawner():
	if spawnable == true:
		timer.start(randi() % spawn_time + 1)
		spawnable = false
	else:
		timer.stop()
	
func firesprite_ex():
	emit_signal("firesprite_hits_player")

func _on_fire_sprite_timer_timeout():
	var instance = fire_sprite.instance()
	add_child(instance)
	rand_x = randi() % int(screen_x)
#	rand_y = randi() % int(screen_y)
	rand_y = $Lava.HEIGHT + 100
	instance.position = Vector2(rand_x,rand_y)
	timer.wait_time = randi() % spawn_time + 1



func _ready():
	get_tree().paused = false
	butn.pause_mode = Node.PAUSE_MODE_PROCESS
	spawner()
	print(screen_x)
	print(screen_y)

func _process(_delta):
	bkgd.set_position(get_node("player/Camera2D").get_camera_screen_center() - b_offset)
	note.set_position(get_node("player/Camera2D").get_camera_screen_center() + n_offest)
	butn.set_position(get_node("player/Camera2D").get_camera_screen_center() + m_offset)
	#fog.position = get_node("player/Camera2D").get_camera_screen_center()
	#moves background and label to correct positions relative to camera
	
	


func _on_menu_pressed():
	get_tree().change_scene("res://menu.tscn")
	
