extends Sprite

var MAX_HEIGHT = -764 #set max_height
var down_offset = 340 #set initial offset
#accounts for position of image being in center of image
onready var HEIGHT = position.y - down_offset #set initial HEIGHT
var lava_on = false

var speed = 1

func _ready():
	if !lava_on:
		speed = 0

func _physics_process(_delta):
	if !lava_on:
		speed = 0
	else:
		speed = 1
	position.x = get_parent().get_node("player/Camera2D").get_camera_screen_center().x
	#move lava image so it is always at the correct x position relative 
	#to camera
	if HEIGHT > MAX_HEIGHT: #only move  lava highter if lava 
		position.y -= speed  # height has not yet exceeded max_height
		HEIGHT = position.y - down_offset #update HEIGT variable

