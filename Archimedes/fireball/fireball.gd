extends RigidBody2D

var lava
var terrain
var first = true

var state = 0 #0 is patrol
var velocity = Vector2(0, 0)
var jump_speed = 150
var speed = 150
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
var stop = false
var on_floor = false

var sight = 10
var dir = 1
var up_dir = Vector2(0, -1)

var vx = 0

func _ready():
	pass
	

	
func _integrate_forces(s):
	if first:
		terrain = get_parent().terrain
		lava = get_parent().lava
		first = false

	var step = s.get_step()
	var lv = s.get_linear_velocity()
	
	on_floor = false
	left = false
	right = false
	stop = false
	jump = false
	
	#find if onfloor
	var fx
	for x in range(s.get_contact_count()):
		if s.get_contact_local_normal(x).dot(up_dir) > 0.6:
			fx = x
			on_floor = true
			jumping = false
			
	
	#calculate friction
	if on_floor:
		vx = abs(lv.x)
		vx -= fric * step
		if vx < 0:
			vx = 0
		lv.x = sign(lv.x) * vx
	else:
		vx = abs(lv.x)
		vx -= air_fric * step
		if vx < 0:
			vx = 0
		lv.x = sign(lv.x) * vx
	
	
	
	#determine behavior
	if state == 0:
		if dir == 1:
			right = true
		elif dir == -1:
			left = true
		if is_dip():
			prints("fall:", str(fall_length(dir)))
			if fall_length(dir) != 1:
				print("switching")
				stop = true
				switch_x_dir()
		if is_wall():
			jump = true
#			if lv.x <= 10 and on_floor:
#				switch_x_dir()
		
	
	
	

	#apply behavior
	if stop:
		lv.x = 0
	
	if on_floor:
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
		#horizontal motion
		if right and not left:
			lv.x += speed * step
			vx = abs(lv.x)
			if vx > max_speed:
				vx = max_speed
			lv.x = sign(lv.x) * vx
			
		if left and not right:
			lv.x += -speed * step
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
	return get_node(lava).get_height()
	
	
func is_dip():
	var next_floor = get_tile(Vector2(position.x + (sight * dir), position.y + 32))
	return (tile_type(next_floor) == -1 and !is_wall())
	
func is_wall():
	var next_floor = get_tile(Vector2(position.x + (sight * dir), position.y))
	return (tile_type(next_floor) != -1)

func fall_length(dire):
	var pos = get_tile(position)
	#print(str(pos))
	var count = 0
	pos.x += dire
	pos.y += 1
	#print(str(pos))
	#print(str(tile_type(pos)))
	var i = 0
	while(tile_type(pos) == -1):
		prints("i: ", str(i))
		pos.y += 1
		count += 1
		if count * 32 > lava_height():
			return -1
		i += 1
	return count
		
	
