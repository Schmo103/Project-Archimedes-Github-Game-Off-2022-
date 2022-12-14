extends Node2D

onready var terrain = get_terrain_path()
onready var lava = get_lava_path()
onready var player = get_node("player")

var lava_on = true
var owens_way = false
var spawning = true
var first = true

onready var timer = $fire_sprite_timer
onready var spawn_time = 10
onready var fire_sprite = load('res://firesprite.tscn')
var spawnable = true
var screen_x = OS.get_window_size().x
var screen_y = OS.get_window_size().y

onready var rand_x
onready var rand_y 

signal firesprite_hits_player 

var js_pos = Vector2(900, 500)
var js_range = 78
#onready var bkgd = $background
#onready var b_offset = Vector2(557, 405)
onready var note = $death_note
var n_offest = Vector2(-174, -104)
onready var butn = $menu
var m_offset = Vector2(-103, 35)
onready var fog = get_node("wavy shader")
onready var hud = $filler_hud
onready var rhud = $HUD
onready var hud_offset = Vector2(-235, -150)
var ready = false
onready var ter = $terrain
onready var lav : Node = $Lava
onready var flag = ter.flag
var enemy_bonus : int = 500
var tile_mlp : int = -10
var score : int = 0
var height_score : int = 0
var player_y_offset : int = 0
var fscore : int = 0
	

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
		rand_x = randi() % (int(screen_x) + int($player/Camera2D.get_camera_screen_center().x - int(screen_x / 2)))
#		rand_y = randi() % int(screen_y)
		rand_y = lav.HEIGHT + 100
		instance.position = Vector2(rand_x,rand_y)
		instance.owens_way = owens_way
		add_child(instance)
		timer.wait_time = randi() % spawn_time + 1
		$'hiss_noise'.play()

func final_hud():
	height_score = player.get_tile(player.position).y * tile_mlp - player_y_offset
	if height_score < 0:
		height_score = 0
	fscore = score + height_score
	hud.text = "Health: 0\nScore: " + str(fscore)
	rhud.set_score(fscore)
	rhud.set_health(0)

func _ready():
	player_y_offset = player.get_tile(player.position).y * tile_mlp
	height_score = player.get_tile(player.position).y * tile_mlp - player_y_offset
	get_tree().paused = false
	butn.pause_mode = Node.PAUSE_MODE_PROCESS
	spawner()
	lav.lava_on = lava_on

func _process(_delta):
	if first:
		lav.lava_on = lava_on
		first = false
		owens_way = false
#	bkgd.set_position(get_node("player/Camera2D").get_camera_screen_center() - b_offset)
	note.set_position(get_node("player/Camera2D").get_camera_screen_center() + n_offest)
	butn.set_position(get_node("player/Camera2D").get_camera_screen_center() + m_offset)
	hud.set_position(get_node("player/Camera2D").get_camera_screen_center() + hud_offset)
	height_score = player.get_tile(player.position).y * tile_mlp - player_y_offset
	if height_score < 0:
		height_score = 0
	fscore = score + height_score
	hud.text = "Health: " + str(player.health) +"\nScore: " + str(fscore)
	rhud.set_score(fscore)
	rhud.set_health(player.health)
	if Input.is_action_pressed("ui_cancel"):
		if get_parent() == get_node("/root"):
			get_tree().change_scene("res://menu.tscn")
		else:
			get_parent().to_menu()
	#fog.position = get_node("player/Camera2D").get_camera_screen_center()
	#moves background and label to correct positions relative to camera
	screen_x = OS.get_window_size().x
	screen_y = OS.get_window_size().y
	if player.position.y <= ter.flag:
		ter.flag_passed()
	
	
func hit_enemy(name, dire, kb):
	for i in range(get_child_count()):
		if get_child(i) == name:
			get_child(i).take_hit(dire, kb)
			
func enemy_killed():
	score += enemy_bonus
	lav.decrease_speed()

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
	
