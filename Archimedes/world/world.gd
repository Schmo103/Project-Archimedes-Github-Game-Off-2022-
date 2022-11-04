extends Node2D
onready var bkgd = $background
onready var b_offset = Vector2(557, 405)
onready var note = $death_note
var n_offest = Vector2(-174, -104)

func _ready():
	pass 

func _process(_delta):
	bkgd.set_position(get_node("player/Camera2D").get_camera_screen_center() - b_offset)
	note.set_position(get_node("player/Camera2D").get_camera_screen_center() + n_offest)
	#moves background and label to correct positions relative to camera
