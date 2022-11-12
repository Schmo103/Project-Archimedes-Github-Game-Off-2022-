extends KinematicBody2D


onready var spawn_time = 5
onready var player_x = get_parent().get_node("player").get_position().x
onready var player_y = get_parent().get_node("player").get_position().y
onready var x_targ
onready var y_targ
func _ready():
	 pass


func realtimereset():
	player_x = get_parent().get_node("player").position.x
	player_y = get_parent().get_node("player").position.y


func _physics_process(_delta):
	realtimereset()
	move_and_slide(Vector2(player_x - self.position.x, player_y - self.position.y), Vector2(0, -1), false, 4, 0.785398, false)
