extends KinematicBody2D
var speed = 250
var velocity = Vector2(0, 0)
var jump = false
var grav = 20
var jump_speed = 500

onready var world = get_parent()

func _ready():
	pass

func die():
	print("You have died")
	get_tree().paused = true
	world.get_node("death_note").visible = true

func _physics_process(_delta):
	velocity.x = 0 #velocity left/right resets
	jump = false
	if Input.is_action_pressed("ui_a"):
		velocity.x -= speed
	if Input.is_action_pressed("ui_d"):
		velocity.x += speed
	if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_w"):
		jump = true
	if is_on_floor():
		if velocity.y > 1:
			velocity.y = 0
		if jump:
			velocity.y -= jump_speed
	else:
		velocity.y += grav
	move_and_slide(velocity, Vector2(0, -1))
	
	#check if still alive
	if position.y >= world.get_node("Lava").HEIGHT:
			die()
