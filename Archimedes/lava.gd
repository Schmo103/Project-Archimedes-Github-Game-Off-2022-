extends Sprite
var MAX_HEIGHT = 0
var down_offset = 340
onready var HEIGHT = position.y - down_offset
var speed = .5

func _process(_delta):
	if HEIGHT > MAX_HEIGHT:
		position.y -= speed
		HEIGHT = position.y - down_offset
