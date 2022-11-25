extends KinematicBody2D

var speed = 40 #set movement speed
var velocity = Vector2(0, 0) #set initial velocity
var jump = false #variable to record if jump button was pressed
var grav = 22 #set gravity speed
var jump_speed = 515 #set jump speed
var fric = 22

var air_fric = 20
var MAXSPEED = 250
var min_air = 0

var player_pos = Vector2()

var sword_posi = 1 #-1 is left, 1 is right
var sword_swinging = false
var reach = 50
var pointer_range = 50
var struck = false
var swing_dir = Vector2(0, -1)
var knockback = 300
var shielded = false
var shield_dir = Vector2()
var max_shield_angle = 0.4 #the closer this is to zero, the narrower the range the shield blocks

var game_over = false
var health = 30

onready var world = get_parent()
onready var sword_a = get_node("sword/Area2D")
onready var shield = $lowered_shield

var js_pos = Vector2(900, 480)
var js_range = 104
var in_bubble = false

func _ready():
	$Camera2D.current = true #make camera "the camera"
	shield.lower_shield()
	shield.set_shield_pos(sword_posi)


func take_hit(dir, kb):
	if !shielded:
		health -= 2
		velocity += dir * kb
		flash(0.1)
		$AudioStreamPlayer.play()
	else:
		if check_block(dir, shield_dir):
			health -= 0
			velocity += dir * kb / 2
			$AudioStreamPlayer2.play()
			#flash(0.1)
		else:
			health -= 2
			velocity += dir * kb
			flash(0.1)
			$AudioStreamPlayer.play()
			
func check_block(swordd, shieldd):
	var nswordd = swordd.rotated(PI)
	return (nswordd.dot(shieldd) >= max_shield_angle)
	

func flash(time):
	material.set("shader_param/flash", 1.0)
	yield(get_tree().create_timer(time), "timeout")
	material.set("shader_param/flash", 0.0)


func set_sword_right(): #puts sword in right position
	sword_posi = 1
	if !sword_swinging:
		$sword.position = Vector2(34, -1)
		$sword.rotation_degrees = 26.4

func set_sword_left(): #puts sword in left position
	sword_posi = -1
	if !sword_swinging:
		$sword.position = Vector2(-34, -1)
		$sword.rotation_degrees = -26.4

func die(): #function cleanup after death and display alert
	print("You have died")
	get_tree().paused = true
	world.get_node("filler_hud").text = "Health: 0"
	world.get_node("death_note").visible = true
	world.get_node("menu").visible = true

func swing_sword(dir):
	#var dir = position.direction_to(m_pos)
	$pointer.visible = false
	sword_swinging = true
	$sword.rotation = dir.angle() + PI / 2
	$sword.position = dir * reach
	yield(get_tree().create_timer(.2), "timeout")
	sword_swinging = false
	struck = false
	if sword_posi == 1:
		set_sword_right()
	else:
		set_sword_left()


func _physics_process(_delta):
	var d
	var m_dir
	var mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos.distance_to(js_pos) <= js_range:
		in_bubble = true
	else:
		in_bubble = false
	var ab_m_pos = mouse_pos + $Camera2D.get_camera_screen_center() - (OS.get_real_window_size() / 2)
	if !in_bubble:
		 m_dir = position.direction_to(ab_m_pos)
	else:
		m_dir = js_pos.direction_to(mouse_pos)
	$pointer.rotation = m_dir.angle() + PI / 2
	$pointer.position = m_dir * pointer_range
		
	player_pos = position
	if(is_on_floor()):
		if(velocity.x > 0):
			velocity.x -= fric
			if(velocity.x < 0): #clamp x
				velocity.x = 0
		if(velocity.x < 0):
			velocity.x += fric
			if(velocity.x > 0): #clamp x
				velocity.x = 0
	else:
		if(velocity.x > 0):
			velocity.x -= air_fric
			if(velocity.x < min_air): #clamp x
				velocity.x = min_air
		if(velocity.x < 0):
			velocity.x += air_fric
			if(velocity.x > -min_air): #clamp x
				velocity.x = -min_air
	jump = false
	if Input.is_action_pressed("ui_a"): #for moving left
		if (velocity.x - speed >= -MAXSPEED):
			velocity.x -= speed
		elif (velocity.x > -MAXSPEED):
			velocity.x = -MAXSPEED
		set_sword_left()
		shield.set_shield_left()
	if Input.is_action_pressed("ui_d"): #for moving right
		if (velocity.x + speed <= MAXSPEED):
			velocity.x += speed
		elif (velocity.x < MAXSPEED):
			velocity.x = MAXSPEED
		set_sword_right()
		shield.set_shield_right()
	if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_w"):
		#for jumping
		jump = true
	if Input.is_action_pressed("ui_rclick"):
		#var rmpos = get_viewport().get_mouse_position() + $Camera2D.get_camera_screen_center() - (OS.get_real_window_size() / 2)
		shielded = true
		$pointer.visible = false
		d = position.direction_to(ab_m_pos)
		shield.swing_shield(m_dir)
	if Input.is_action_just_released("ui_rclick"):
		shielded = false
		shield.lower_shield()
	if Input.is_action_just_pressed("ui_lclick") and !shielded:
		#var mpos = get_viewport().get_mouse_position() + $Camera2D.get_camera_screen_center() - (OS.get_real_window_size() / 2)
		d = position.direction_to(ab_m_pos)
		swing_sword(m_dir)
	if is_on_floor():
		if velocity.y > 1:
			velocity.y = 0 #if on floor, gravity doesnt continue increasing
		if jump:
			velocity.y -= jump_speed #jumps player velocity
	else:
		velocity.y += grav #adds gravity
	if is_on_ceiling():
		if velocity.y < -1:
			velocity.y = 0
	move_and_slide(velocity, Vector2(0, -1), false, 4, 0.785398, false) #moves player

	#check if still alive
	if position.y >= get_parent().get_node("Lava").HEIGHT or health <= 0:
		#checks if player has fallen below lava
		die()
	if sword_swinging:
		for a in sword_a.get_overlapping_bodies():
			if a.is_in_group("enemies") and !struck:
				struck = true
				get_parent().hit_enemy(a, position.direction_to(a.this_pos), knockback)
	if !sword_swinging and !shielded:
		$pointer.visible = true
		

func explosion(pos, emax, emin, ran, crit):
	var force_dir = pos.direction_to(position)
	if force_dir == Vector2(0, 0):
		force_dir = Vector2(1, 0)
	var mag = (pos - position).length()
	var force
	if !(mag > ran):
		flash(0.1)
		if mag <= float(crit):
			force = emax
		else:
			force = ((ran - mag) / ran) * emax
			if force < emin:
				force = emin
		velocity += (force_dir * force)
		health -= 1
		$AudioStreamPlayer.play()



func _on_World_firesprite_hits_player(pos, emax, emin, ran, crit):
	#print("got explositon pos: " + str(pos))
	explosion(pos, emax, emin, ran, crit)
	
#	var force_dir = pos.direction_to(position)
#	if force_dir == Vector2(0, 0):
#		force_dir = Vector2(1, 0)
#	var mag = (pos - position).length()
#	var force
#	if !(mag > ran):
#		if mag <= crit:
#			force = emax
#		else:
#			force = (ran - mag) / emax
#			if force < emin:
#				force = emin
#		velocity += (force_dir * force)
