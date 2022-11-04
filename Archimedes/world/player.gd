extends KinematicBody2D
var speed = 250 #set movement speed
var velocity = Vector2(0, 0) #set initial velocity
var jump = false #variable to record if jump button was pressed
var grav = 20 #set gravity speed
var jump_speed = 500 #set jump speed

var sword_pos = 1 #-1 is left, 1 is right

var sword_swinging = false

var game_over = false

onready var world = get_parent()

func _ready():
	$Camera2D.current = true #make camera "the camera"
	
func set_sword_right(): #puts sword in right position
	if !sword_swinging:
		$sword.position = Vector2(34, -1)
		$sword.rotation_degrees = 26.4
		sword_pos = 1 
	
func set_sword_left(): #puts sword in left position
	if !sword_swinging:
		$sword.position = Vector2(-34, -1)
		$sword.rotation_degrees = -26.4
		sword_pos = -1

func die(): #function cleanup after death and display alert
	print("You have died")
	get_tree().paused = true
	world.get_node("death_note").visible = true
	world.get_node("menu").visible = true

func _physics_process(_delta):
	velocity.x = 0 #velocity left/right resets
	jump = false 
	if Input.is_action_pressed("ui_a"): #for moving left
		velocity.x -= speed
		set_sword_left()
	if Input.is_action_pressed("ui_d"): #for moving right
		velocity.x += speed
		set_sword_right()
	if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_w"):
		#for jumping
		jump = true
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://menu.tscn")
	if is_on_floor():
		if velocity.y > 1:
			velocity.y = 0 #if on floor, gravity doesnt continue increasing
		if jump:
			velocity.y -= jump_speed #jumps player velocity
	else:
		velocity.y += grav #adds gravity
	move_and_slide(velocity, Vector2(0, -1)) #moves player
	
	#check if still alive
	if position.y >= get_parent().get_node("Lava").HEIGHT:
		#checks if player has fallen below lava
		die()
