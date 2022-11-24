extends KinematicBody2D

var speed = 550


onready var spawn_time = 10
onready var player = get_parent().get_node("player").get_position()
onready var attacking = true
onready var exploding = false
onready var coasting = false
var started = false
var collide_range = 20
var coast_range = 500
var velocity = Vector2()

onready var sound = $'explosion_sound'
onready var sound2 = $'explosion_sound2'
onready var sound3 = $'explosion_sound3'

var owens_way = false
var target = Vector2()
var ex_force_max = 600

var ex_force_min = 600
var ex_force_range = 100
var ex_crit_range = 64


func _ready():
	 pass


func realtimereset():
	player = get_parent().get_node("player").player_pos
	


func _physics_process(delta):
# warning-ignore:return_value_discarded
	realtimereset()
	var gravity = Vector2(0, 400)
	if coasting:
#		if (player - self.position).length() < collide_range:
#			coasting = false
#			exploding = true
#		else:
#			move_and_slide(velocity, Vector2(0, -1), false, 4, 0.785398, false)
		if owens_way:
			if (target - self.position).length() < collide_range:
				coasting = false
				exploding = true
			else:
				move_and_slide(velocity, Vector2(0, -1), false, 4, 0.785398, false)
		else: #micahs way
			if !(((position + (velocity * delta)) - player).length()) < (position - player).length():
				coasting = false
				exploding = true
			else:
				move_and_slide(velocity, Vector2(0, -1), false, 4, 0.785398, false)
	if attacking:
		realtimereset()
		velocity += position.direction_to(player) * speed
		move_and_slide(velocity, Vector2(0, -1), false, 4, 0.785398, false)
		if (player - self.position).length() < coast_range:
			target = player
			attacking = false
			coasting = true
		else:
			velocity = Vector2(0,0)
		
	if exploding:
# warning-ignore:return_value_discarded
#		emit_signal("firesprite_hits_player")
		get_parent().firesprite_ex(position, ex_force_max, ex_force_min, ex_force_range, ex_crit_range)
#		$Particles2D.position = self.position
		$Particles2D.emitting = true
		#$blast.position = position
		#$blast.emit()
#		$Particles2D.emitting = false
		$Sprite.visible = false
		var choice_sound = randi() % 2
		if choice_sound == 0:
			sound.play()
		elif choice_sound == 1:
			sound2.play()
		elif choice_sound == 2:
			sound3.play()
		if started == false:
			$Timer.start(0.4)
			started = true
		exploding = false
		








func _on_Timer_timeout():
#	print("received")
	self.queue_free()
