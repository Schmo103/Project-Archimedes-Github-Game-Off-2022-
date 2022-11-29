extends Node2D

var ens = []

var s = ""

func printv(b):
	s += "enemies: ["
	var i = 1
	for c in b:
		s += "Vector2" 
		s += str(c)
		if !(i == b.size()):
			s += ", "
		i += 1
	s += "]"
	print(s)
	

func _ready():
	for a in get_child_count():
		if get_child(a).is_in_group("enemies"):
			ens.append(get_child(a).position)
	printv(ens)
	
	



func _on_Timer_timeout():
	get_tree().quit()
