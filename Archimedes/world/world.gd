extends Node2D

onready var terrain = get_terrain_path()
onready var lava = get_lava_path()

var lava_on = true
var owens_way = false
var spawning = true
var first = true

onready var timer = $fire_sprite_timer
onready var spawn_time = 1
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
	
func firesprite_ex(pos, ex_max, ex_min, ex_ran, crit):
	emit_signal("firesprite_hits_player", pos, ex_max, ex_min, ex_ran, crit)

func _on_fire_sprite_timer_timeout():
	if spawning:
		var instance = fire_sprite.instance()
		rand_x = randi() % int(screen_x)
#		rand_y = randi() % int(screen_y)
		rand_y = $Lava.HEIGHT + 100
		instance.position = Vector2(rand_x,rand_y)
		instance.owens_way = owens_way
		add_child(instance)
		timer.wait_time = randi() % spawn_time + 1



func _ready():
	get_tree().paused = false
	butn.pause_mode = Node.PAUSE_MODE_PROCESS
	spawner()
	$Lava.lava_on = lava_on

func _process(_delta):
	if first:
		$Lava.lava_on = lava_on
		first = false
	bkgd.set_position(get_node("player/Camera2D").get_camera_screen_center() - b_offset)
	note.set_position(get_node("player/Camera2D").get_camera_screen_center() + n_offest)
	butn.set_position(get_node("player/Camera2D").get_camera_screen_center() + m_offset)
	if Input.is_action_pressed("ui_cancel"):
		if get_parent() == get_node("/root"):
			get_tree().change_scene("res://menu.tscn")
		else:
			get_parent().to_menu()
	#fog.position = get_node("player/Camera2D").get_camera_screen_center()
	#moves background and label to correct positions relative to camera
	
	


func _on_menu_pressed():
	if get_parent() == get_node("/root"):
		get_tree().change_scene("res://menu.tscn")
	else:
		get_parent().to_menu()
		
func get_lava_path():
	if get_parent() == get_node("/root"):
		return "/root/World/Lava"
	else:
		return "/root/universe/World/Lava"
		
func get_terrain_path():
	if get_parent() == get_node("/root"):
		return "/root/World/terrain"
	else:
		return "/root/universe/World/terrain"
	
