extends CanvasLayer
onready var health_bar = get_node("Node2D/Control/ProgressBar")
onready var score_tracker = get_node("Node2D/Control/ProgressBar2/Label")

func set_health(num : float):
	health_bar.set_value(num)

func set_score(num : int):
	if num == 0:
		score_tracker.set_text("score 00")
	else:
		score_tracker.set_text("score " + str(num))
	
func _ready():
	set_health(50)
