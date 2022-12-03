extends Sprite

var MAX_HEIGHT = -760 #set max_height
var down_offset = 300 #set initial offset
#accounts for position of image being in center of image
onready var HEIGHT = position.y - down_offset #set initial HEIGHT
export var lava_on = true
var ignore : bool = true

var sufferage : float = 0.5
var gain : float = 0.4
var max_speed : float = 4
var start_speed = 1.75
var speed = start_speed

func _ready():
	if lava_on:
		speed = start_speed
	else:
		speed = 0
		
func get_height():
	return HEIGHT

func _physics_process(_delta):
	position.x = get_parent().get_node("player/Camera2D").get_camera_screen_center().x
	#move lava image so it is always at the correct x position relative 
	#to camera
	if HEIGHT > MAX_HEIGHT or ignore: #only move  lava highter if lava 
		position.y -= speed  # height has not yet exceeded max_height
		HEIGHT = position.y - down_offset #update HEIGT variable

func decrease_speed():
	speed -= sufferage

func _on_Timer_timeout():
	if lava_on and !(speed > max_speed):
		speed += gain
