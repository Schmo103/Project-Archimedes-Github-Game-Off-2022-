extends Sprite
var MAX_HEIGHT = 0
onready var HEIGHT = position.y - 300
var speed = .5

func _process(_delta):
	if HEIGHT > MAX_HEIGHT:
		position.y -= speed
		HEIGHT = position.y - 300
