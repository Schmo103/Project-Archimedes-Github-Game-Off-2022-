extends Sprite

var low_shield_right_pos = Vector2(36, 0)
var low_shield_left_pos = Vector2(-36, 0)

var high_shield_right_pos = Vector2(36, 0)
var high_shield_left_pos = Vector2(-36, 0)

onready var up_shield = get_parent().get_node("raised_shield")

var shield = 0 #0 is down 1 is up
var pointing = 1 #1 is right -1 is left
var reach = 40

func _ready():
	set_shield_pos(-get_parent().sword_posi)
	
	
func swing_shield(dir):
	raise_shield()
	#var dir = get_parent().position.direction_to(m_pos)
	get_parent().shield_dir = dir
	up_shield.rotation = dir.angle() 
	up_shield.position = dir * reach
	


func raise_shield():
	shield = 1
	visible = false
	up_shield.visible = true
	
func lower_shield():
	shield = 0
	visible = true
	up_shield.visible = false
	if get_parent().sword_posi == 1:
		set_shield_right()
	else:
		set_shield_left()

func set_shield_pos(dire):
	if dire == 1:
		set_shield_right()
	else:
		set_shield_left()

func set_shield_right():
		position = low_shield_left_pos
		up_shield.position = high_shield_right_pos
		
func set_shield_left():
		position = low_shield_right_pos
		up_shield.position = high_shield_left_pos
		
		
