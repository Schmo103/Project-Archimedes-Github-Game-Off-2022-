extends Node2D
onready var bkgd = $background
onready var b_offset = Vector2(557, 405)
onready var note = $death_note
var n_offest = Vector2(-174, -104)
onready var butn = $menu
var m_offset = Vector2(-103, 35)

func _ready():
	get_tree().paused = false
	butn.pause_mode = Node.PAUSE_MODE_PROCESS

func _process(_delta):
	bkgd.set_position(get_node("player/Camera2D").get_camera_screen_center() - b_offset)
	note.set_position(get_node("player/Camera2D").get_camera_screen_center() + n_offest)
	butn.set_position(get_node("player/Camera2D").get_camera_screen_center() + m_offset)
	#moves background and label to correct positions relative to camera


func _on_menu_pressed():
	get_tree().change_scene("res://menu.tscn")
	
