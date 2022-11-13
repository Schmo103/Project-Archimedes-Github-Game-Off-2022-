extends RigidBody2D

var lava
var terrain

var state = 0 #0 is patrol
var velocity = Vector2(0, 0)
var jump_speed = 125
var speed = 200
var air_speed = 60
var max_speed = 100
var gravity = 130
var fric = 60
var air_fric = 70
var zoom = 90

var going_right = false
var going_left = false
var jumping = false

var jump = false
var left = false
var right = true
var on_floor = false

var sight = 30
var dir = 1
var up_dir = Vector2(0, -1)

var vx = 0

func _ready():
	terrain = get_parent().terrain
	lava = get_parent().lava
#	print(str(fall_length(-1)))
#	print(lava)
#	print(str(get_node(lava).HEIGHT))
#	print(str(get_tile(position)))
#	print(str(is_dip()))
	

	
func _integrate_forces(s):
	var step = s.get_step()
	var lv = s.get_linear_velocity()
	
	on_floor = false
	left = false
	right = false
	jump = false
	
	
	#determine behavior
	if state == 0:
		if is_dip():
			switch_x_dir()
		if dir == 1:
			right = true
		elif dir == -1:
			left = true
		if is_wall():
			jump = true
			if lv.x >= zoom:
				right = false
				left = false
			elif lv.x <= 30:
				switch_x_dir()
		
	
	
	
	#calculate physics
	var fx
	for x in range(s.get_contact_count()):
		if s.get_contact_local_normal(x).dot(up_dir) > 0.6:
			fx = x
			on_floor = true
			jumping = false
	
	if on_floor:
		#friction
		vx = abs(lv.x)
		vx -= fric * step
		if vx < 0:
			vx = 0
		lv.x = sign(lv.x) * vx
		
		#horizontal motion
		if right:
			#print("right")
			lv.x += speed * step
			vx = abs(lv.x)
			if vx > max_speed:
				vx = max_speed
			lv.x = sign(lv.x) * vx
			
		if left:
			#print("left")
			lv.x += -speed * step
			vx = abs(lv.x)
			if vx > max_speed:
				vx = max_speed
			lv.x = sign(lv.x) * vx
		
		#vertical motion
		lv.y = 0
		if jump:
			lv.y -= jump_speed
			jumping = true
	else:
		#friction
		vx = abs(lv.x)
		vx -= air_fric * step
		if vx < 0:
			vx = 0
		lv.x = sign(lv.x) * vx
		
		#horizontal motion
		if right and not left:
			lv.x += air_speed * step
			vx = abs(lv.x)
			if vx > max_speed:
				vx = max_speed
			lv.x = sign(lv.x) * vx
			
		if left and not right:
			lv.x += -air_speed * step
			vx = abs(lv.x)
			if vx > max_speed:
				vx = max_speed
			lv.x = sign(lv.x) * vx
		
		#gravity
		lv.y += gravity * step
	s.set_linear_velocity(lv)
	
func switch_x_dir():
	if dir == 1:
		dir = -1
	else:
		dir = 1
	#velocity += -linear_velocity
	#print("called : " + str(i))

	
func get_tile(pos):
	var x = pos.x - (int(pos.x) % 32)
#	print(str(pos.x))
#	print(str(x))
	var y = pos.y - (int(pos.y) % 32)
	x /= 32
	y /= 32
	return Vector2(x, y)
	
func tile_type(pos):
	return get_node(terrain).get_cellv(pos)
	
func lava_height():
	return get_node(lava).HEIGHT
	
	
func is_dip():
	var next_floor = get_tile(Vector2(position.x + (sight * dir), position.y + 32))
	return (tile_type(next_floor) == -1 and !is_wall())
	
func is_wall():
	var next_floor = get_tile(Vector2(position.x + (sight * dir), position.y))
	return (tile_type(next_floor) != -1)

func fall_length(dir):
	var pos = get_tile(position)
	#print(str(pos))
	var count = 0
	pos.x += dir
	pos.y += 1
	#print(str(pos))
	#print(str(tile_type(pos)))
	while(tile_type(pos) == -1):
		pos.y += 1
		count += 1
	return count
		
	
