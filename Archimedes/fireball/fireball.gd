extends RigidBody2D

var lava
var terrain
var player
var first = true
export var en = false

var state = 0 #0 is patrol 1 is hunting
var velocity = Vector2(0, 0)

var jump_speed = 320

var walk_speed = 200
var max_walk_speed = 200

var jog_speed = 250
var max_jog_speed = 300

var run_speed = 300
var max_run_speed = 350

var air_speed = 60

var speed = walk_speed
var max_speed = max_walk_speed

var yields = []

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

var health = 3
var dying = false

var hunting_enabled = true
var seeing_player = false

var this_pos = Vector2()
onready var ray_left = $RayCast_left
onready var ray_right = $RayCast_right
onready var ray_ldown = $raycast_ldown
onready var ray_rdown = $raycast_rdown
onready var ray_lup = $RayCast_uleft
onready var ray_rup = $RayCast_uright

var knockback = 200
var knocked = false
var knock_dir = Vector2(1, 0)
var sword_swinging = false
var reach = 15
var struck = false
var strike_range = 70
onready var sword_a = get_node("sword/Area2D")

var vx = 0

func _ready():
	this_pos = position
	
func _physics_process(_delta):
	if first:
		player = get_parent().player
	old_pos = this_pos
	this_pos = position
	if old_pos == this_pos:
		s_count += 1
	else:
		just_uf = false
		uf_c = 1
		s_count = 0
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, player.position)
	if result:
		if instance_from_id(result["collider_id"]).is_in_group("player"):
			seeing_player = true
		else:
			seeing_player = false
	
func take_hit(dire, kb):
#	if dying == false:
	health -= 1
	knocked = true
	knock_dir = dire
	knockback = kb
	flash(0.1)
	prints(name, ": hit health: ", health)
	if health <= 0:
		dying = true
		$AudioStreamPlayer.play()
		$Particles2D.visible = true
		yield(get_tree().create_timer(1),"timeout")
		queue_free()

func flash(time):
	material.set("shader_param/flash", 1.0)
	yield(get_tree().create_timer(time), "timeout")
	material.set("shader_param/flash", 0.0)

func swing_sword():

	var dire = position.direction_to(player.position)
	sword_swinging = true
	$sword.visible = true
	$sword.rotation = dire.angle() + PI / 2
	$sword.position = dire * reach
	$sword_swing_timer.start()
	
func _on_sword_swing_timer_timeout():
	$sword.visible = false
	sword_swinging = false
	struck = false


	if dying == false:
		yield(get_tree().create_timer(1),"timeout")
		var dire = position.direction_to(player.position)
		sword_swinging = true
		$sword.visible = true
		$sword.rotation = dire.angle() + PI / 2
		$sword.position = dire * reach
		yield(get_tree().create_timer(.4), "timeout")
		$sword.visible = false
		sword_swinging = false
		struck = false

	
func _integrate_forces(s):
	var out = Input.is_action_pressed("ui_s") and en
	if out:
		print("out " + str(name))
		prints("itr: ", str(i))
	if first:
		terrain = get_parent().terrain
		lava = get_parent().lava
		player = get_parent().player
		first = false

	var step = s.get_step()
	var lv = s.get_linear_velocity()
	if Vector2(abs(lv.x), abs(lv.y)) == Vector2():
		freeze += 1
#		print("Alert: frozen " + str(freeze) + " vel: " + str(lv))
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
	
	if seeing_player and hunting_enabled:
		state = 1
	else:
		
		state = 0
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
		
	if knocked:
		lv += knockback * knock_dir
	
	#determine behavior
	if state == 0:
		if freeze >= 2:
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
			if out:
				prints("is_dip: true")
			
			stop = true
			switch_x_dir()
		if get_wall_dist(dir, 0) != 301:
			if get_wall_dist(dir, 0) <= wall_sight and get_wall_dif(dir) > 32:
				jump = true
				if out:
					prints("is_wall: true")
	elif state == 1:
#		if freeze >= 2:
#			switch_x_dir()
#			freeze = 0
		dir = sign(player.position.x - this_pos.x)
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
			if out:
				prints("is_dip: true")
			
			stop = true
#			switch_x_dir()
		if get_wall_dist(dir, 0) != 301:
			if get_wall_dist(dir, 0) <= wall_sight and get_wall_dif(dir) > 32:
				jump = true
				if out:
					prints("is_wall: true")
		
		
	
	
	

	#apply behavior
	if stop:
		if out:
				prints("stop: true")
		lv.x = 0
	
	if on_floor:
		#horizontal motion
		if right and !stop:
			#print("right")
			lv.x += speed * step
			vx = abs(lv.x)
			if vx > max_speed:
				vx = max_speed
			lv.x = sign(lv.x) * vx
			
		if left and (state == 0 or !stop):
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
		if right and (state == 0 or !stop):
			lv.x += speed * step
			vx = abs(lv.x)
			if vx > max_speed:
				vx = max_speed
			lv.x = sign(lv.x) * vx
			
		if left and (state == 0 or !stop):
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
	
	if s_count >= 5 and state == 0:
			prints(name, ": EMERGENCY UNFREEZE!!")
#			uf_c += 1
#			just_uf = true
#			lv.y = 5 * uf_c
			switch_x_dir()
	
	s.set_linear_velocity(lv)
	i += 1
	knocked = false
	
	if (this_pos - player.position).length() <= strike_range and !sword_swinging and !dying:
		swing_sword()
	if sword_swinging:
		for a in sword_a.get_overlapping_bodies():
			if a.is_in_group("player") and !struck:
				struck = true
				get_parent().hit_enemy(a, position.direction_to(a.position), knockback)

func switch_x_dir():
	if dir == 1:
		dir = -1
	else:
		dir = 1

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
	
func get_wall_dist(dire, u):
	if u == 0:
		if dire == 1:
			#ray_right.force_raycast_update()
			if ray_right.is_colliding():
				return (ray_right.get_collision_point() - this_pos).length()
			else: 
				return 301
		else:
			#ray_left.force_raycast_update()
			if ray_left.is_colliding():
				return (ray_left.get_collision_point() - this_pos).length()
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
	
func is_dip():
	var next_floor = get_tile(Vector2(this_pos.x + (sight * dir), this_pos.y + 32))
	return (tile_type(next_floor) == -1 and !is_wall())
	
func is_wall():
	var next_floor = get_tile(Vector2(this_pos.x + (wall_sight * dir), this_pos.y))
	return (tile_type(next_floor) != -1)
		
	


