extends RigidBody2D

var lava
var terrain
var first = true
export var en = false

var state = 0 #0 is patrol
var velocity = Vector2(0, 0)
var jump_speed = 320
var speed = 260
var air_speed = 60
var max_speed = 200
var gravity = 13
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
var on_left = false
var on_right = false

var vision = 300
var wall_sight = 20
var sight = 8
var dir = 1
var up_dir = Vector2(0, -1)
var is_dip = false

var i = 0
var freeze = 0
var old_pos = Vector2()
var stuck = false
var s_count = 0
var just_uf = false
var uf_c = 1

var this_pos = Vector2()
onready var ray_left = $RayCast_left
onready var ray_right = $RayCast_right
onready var ray_ldown = $raycast_ldown
onready var ray_rdown = $raycast_rdown
onready var ray_lup = $RayCast_uleft
onready var ray_rup = $RayCast_uright

var vx = 0

func _ready():
#	ray_left.cast_to.x = vision
#	ray_right.cast_to.x = vision
#	ray_ldown.cast_to.y = -vision
#	ray_rdown.cast_to.y = vision
#	ray_lup.cast_to.x = -vision
#	ray_rup.cast_to.x = vision
	
	this_pos = position
	prints("ray fall: ", str(ray_fall(1)))
	prints("wall dif right: ", get_wall_dif(1))
	prints("wall dif left: ", get_wall_dif(-1))
	
func _physics_process(_delta):
	old_pos = this_pos
	this_pos = position
	if old_pos == this_pos:
		s_count += 1
		print("stuck: " + str(s_count))
	else:
		just_uf = false
		uf_c = 1
		s_count = 0
	

	
func _integrate_forces(s):
	var out = Input.is_action_pressed("ui_s") and en
	if out:
		print("out " + str(name))
		prints("itr: ", str(i))
	if first:
		terrain = get_parent().terrain
		lava = get_parent().lava
		first = false
		prints(str(name), ": fall_lenght ", str(fall_length(-1)))
		prints("get tile :", str(get_tile(position)))

	var step = s.get_step()
	var lv = s.get_linear_velocity()
	if Vector2(abs(lv.x), abs(lv.y)) == Vector2():
		freeze += 1
		print("Alert: frozen " + str(freeze) + " vel: " + str(lv))
	else: 
		freeze = 0
	if out:
		prints("old lv: ", str(lv))
	
	on_floor = false
	left = false
	right = false
	stop = false
	jump = false
	on_left = false
	on_right = false
	is_dip = false
	
	#find if onfloor
	var fx
	for x in range(s.get_contact_count()):
		if s.get_contact_local_normal(x).dot(up_dir) > 0.6:
			fx = x
			on_floor = true
			jumping = false
		#find if on left and right
		if s.get_contact_local_normal(x).dot(Vector2(1, 0)) > 0.6:
			on_right = true
		if s.get_contact_local_normal(x).dot(Vector2(-1, 0)) > 0.6:
			on_left = true
	
			
	if out:
		prints("on_floor: ", str(on_floor))
	
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
	
	if out:
		prints("lv after friction: ", str(lv))
		prints("dir: ", str(dir))
		prints("state: ", str(state))
	
	#determine behavior
	if state == 0:
		if freeze >= 2:
			print("thaw")
			switch_x_dir()
			freeze = 0
		if dir == 1:
			right = true
			if out:
				prints("right: true ")
		elif dir == -1:
			left = true
			if out:
				prints("left: true ")
		if ray_fall(dir) - 9 > 0:
			is_dip = true
		if get_downr_dif(dir) > 32:
			#prints("fall:", str(fall_length(dir)))
			if out:
				prints("is_dip: true")
			
			if ray_fall(dir) - 9 > 33:
				prints("fl", ray_fall(dir) - 9)
				print("switching")
				stop = true
				switch_x_dir()
			else:
				if fall_length(dir) > 96 and fall_length(dir) != -1:
					prints("fl", fall_length(dir))
					print("switching")
					stop = true
					switch_x_dir()
		if get_wall_dist(dir, 0) != null:
			if abs(get_wall_dist(dir, 0)) <= wall_sight and get_wall_dif(dir) > 5:
				jump = true
				if out:
					prints("is_wall: true")
#			if lv.x <= 10 and on_floor:
#				switch_x_dir()
		
	
	
	

	#apply behavior
	if stop:
		if out:
				prints("stop: true")
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
			
		if out:
			prints("speed after apply motion: ", str(lv))
		
		#gravity
		lv.y += gravity
		#lv += s.get_total_gravity()
		if out:
			prints("speed after apply gravity: ", str(lv))
			
			
		if on_right and lv.x > 0:
			lv.x = 0
		if on_left and lv.x < 0:
			lv.x = 0
		if out:
			prints("speed after apply wall_check: ", str(lv))
	
	if s_count >= 5:
			print("EMERGENCY UNFREEZE!!")
			uf_c += 1
			just_uf = true
			lv.y = 5 * uf_c
	
	s.set_linear_velocity(lv)
	i += 1
	
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
	x = int(x)
	y /= 32
	y = int(y)
	return Vector2(x, y)
	
func tile_type(pos):
	return get_node(terrain).get_cellv(pos)
	
func lava_height():
	return get_node(lava).get_height()
	
	
func is_dip():
	var next_floor = get_tile(Vector2(this_pos.x + (sight * dir), this_pos.y + 32))
	return (tile_type(next_floor) == -1 and !is_wall())
	
func is_wall():
	var next_floor = get_tile(Vector2(this_pos.x + (wall_sight * dir), this_pos.y))
	return (tile_type(next_floor) != -1)
	
func get_wall_dist(dire, u):
	if u == 0:
		if dire == 1:
			if $RayCast_right.is_colliding():
				return ($RayCast_right.get_collision_point() - this_pos).length()
			else: 
				return 301
		else:
			if $RayCast_left.is_colliding():
				return ($RayCast_left.get_collision_point() - this_pos).length()
			else: 
				return 301
	else:
		if dire == 1:
			if ray_rup.is_colliding():
				return (ray_rup.get_collision_point() - this_pos).length()
			else: 
				return 301
		else:
			if ray_lup.is_colliding():
				return (ray_lup.get_collision_point() - this_pos).length()
			else: 
				return 301
				
func get_wall_dif(dire):
	return get_wall_dist(dire, 1) - get_wall_dist(dire, 0)
		
			
func get_downr_dif(dire):
	var lenf
	var lenb
	if dire == 1:
		if ray_rdown.is_colliding():
			lenf = (ray_rdown.get_collision_point() - this_pos).length()
		else:
			lenf = 301
		if ray_ldown.is_colliding():
			lenb = (ray_ldown.get_collision_point() - this_pos).length()
		else:
			lenb = 301
	else:
		if ray_rdown.is_colliding():
			lenb = (ray_rdown.get_collision_point() - this_pos).length()
		else:
			lenb = 301
		if ray_ldown.is_colliding():
			lenf = (ray_ldown.get_collision_point() - this_pos).length()
		else:
			lenf = 301
	return lenf - lenb
			
			
func ray_fall(dire):
	if dire == 1:
		if $raycast_rdown.is_colliding():
			return ($raycast_rdown.get_collision_point() - ($raycast_rdown.position + this_pos)).length()
		else: 
			return 301
	else:
		if $raycast_ldown.is_colliding():
			return ($raycast_ldown.get_collision_point() - ($raycast_ldown.position + this_pos)).length()
		else: 
			return 301

func fall_length(dire):
	var pos = get_tile(this_pos)
	#print(str(pos))
	var count = 0
	pos.x += dire
	pos.y += 1
	#print(str(pos))
	#print(str(tile_type(pos)))
	var i = 0
	while(tile_type(pos) == -1):
		
#		prints("i: ", str(i))
#		prints("pos: ", str(pos))
#		prints("tiletype: ", str(tile_type(pos)))
		var start_p = pos
		pos.y += 1
		count += 1
		if (count * 32) > lava_height():
			prints("count: ", str(count), "lava height:", lava_height())
			return -1
		i += 1
	return count
		
	
