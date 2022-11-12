extends KinematicBody2D

var speed = 400


onready var spawn_time = 10
onready var player = get_parent().get_node("player").get_position()
onready var attacking = true
onready var exploding = false
onready var coasting = false
var collide_range = 20
var coast_range = 500
var velocity = Vector2()
func _ready():
	 pass


func realtimereset():
	player = get_parent().get_node("player").position
	


func _physics_process(_delta):
# warning-ignore:return_value_discarded
	realtimereset()
	var gravity = Vector2(0, 400)
	if coasting:
		if (player - self.position).length() < collide_range:
			coasting = false
			exploding = true
		move_and_slide(velocity, Vector2(0, -1), false, 4, 0.785398, false)
	if attacking:
		realtimereset()
		velocity += position.direction_to(player) * speed
		move_and_slide(velocity, Vector2(0, -1), false, 4, 0.785398, false)
		if (player - self.position).length() < coast_range:
			attacking = false
			coasting = true
		else:
			velocity = Vector2(0,0)
		
	if exploding:
# warning-ignore:return_value_discarded
#		emit_signal("firesprite_hits_player")
		get_parent().firesprite_ex()
		self.queue_free()

