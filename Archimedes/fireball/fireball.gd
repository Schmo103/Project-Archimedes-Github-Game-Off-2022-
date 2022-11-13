extends RigidBody2D

var lava
var terrain
var state = 0 #0 is patrol
var velocity = Vector2(0, 0)
var dir = Vector2(-1, 0)
var speed = 250
var sight = 100
var i = 0

func _ready():
	terrain = get_parent().terrain
	lava = get_parent().lava
	print(str(is_dip()))
	
func move_right():
	velocity.x += speed
	dir.x = 1
	
func move_left():
	velocity.x -= speed
	dir.x = -1
	
func switch_x_dir():
	if dir.x == 1:
		dir.x = -1
	else:
		dir.x = 1
	velocity += -linear_velocity
	i += 1
	
	
func get_tile(pos):
	var x = pos.x - (int(pos.x) % 64)
	var y = pos.y - (int(pos.y) % 64)
	x /= 64
	y /= 64
	return Vector2(x, y)
	
func is_dip():
	var next_floor = get_tile(Vector2(position.x + (sight * dir.x), position.y + 64))
	return (get_node(terrain).get_cellv(next_floor) == -1)
	
func is_wall():
	var next_floor = get_tile(Vector2(position.x + (sight * dir.x), position.y))
	return (get_node(terrain).get_cellv(next_floor) != -1)

func _physics_process(delta):
	velocity = Vector2()
	if position.y > get_node(lava).HEIGHT + 32:
		#visible = false
		pass
	if state == 0:
		if is_wall() or is_dip():
			switch_x_dir()
		velocity.x += speed * dir.x
	#move_right()
	apply_central_impulse(velocity * delta)
