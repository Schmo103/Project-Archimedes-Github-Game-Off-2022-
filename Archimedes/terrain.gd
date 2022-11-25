extends TileMap

export var chunk_num = 10
export var max_x_dist = 6
export var max_y_dist = 3
var test_chunk = [12,11,2,100,8,9,10]
var test_chunk2 = [12,2,100,8,10]
export var placer = Vector2(11,9)
var direction = 0
var ready = true
onready var time = $Timer
var choice
# 0 = start tile, 1 = 
var tile_pos_list = [-2,-1]
var first_tile_placement = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	choose_direction()
#	for i in chunk_num:
##		randomize()
##		choice = randi() % 2 +1
##		if choice == 1: 
##			read_chunk(test_chunk2)
##		elif choice == 2:
##			read_chunk(test_chunk)
#		read_chunk(test_chunk)
#		choose_direction()
#		move_placer(max_x_dist,max_y_dist, i)
#	var chunk_num_testing = [-2,-1]
#	for i in chunk_num:
#		chunk_num_testing.append(i + 1)
#	print(chunk_num_testing)
#	print(tile_pos_list)

func choose_direction():
	direction = randi() % 2 +1
	tile_pos_list.append(direction)
#	if first_tile_placement == true:
#		tile_pos_list.append(0)
#		first_tile_placement = false
#	elif first_tile_placement == false:
#		tile_pos_list.append(direction)
	

func move_placer(x_dist, y_dist, tile_num):
	randomize()
#	if direction == 1:
#		placer -= Vector2(randi() % x_dist + 3, randi() % y_dist + 1)
#	if direction == 2:
#		placer += Vector2(randi() % x_dist - 3,randi() % y_dist - 1)
	
	if direction == 1:
		var x = randi() % x_dist + 4
		if x > 6:
			x = 5 
		var y = randi() % y_dist + 2
		if y > 3:
			y = 2
		var top_tile = tile_pos_list[tile_num]
		var middle_tile = tile_pos_list[tile_num - 1]
		var bottom_tile = tile_pos_list[(tile_num - 2)]
		if (top_tile == bottom_tile or bottom_tile == 0) and top_tile != middle_tile:
			y = 3
			print('space ' + str(tile_num))
		placer -= Vector2(x, y)
	if direction == 2:
		var x = randi() % x_dist + 4
		if x > 6:
			x = 4
		var y = randi() % x_dist + 2
		if y > 3:
			y = 2
		var top_tile = tile_pos_list[tile_num]
		var middle_tile = tile_pos_list[tile_num - 1]
		var bottom_tile = tile_pos_list[(tile_num - 2)]
		if (top_tile == bottom_tile or bottom_tile == 0) and top_tile != middle_tile:
			y = 3
			print("space " + str(tile_num))
		placer += Vector2(x, -y)



func read_chunk(chunk):
	var start_pos = placer
	for i in chunk.size():
		if chunk[i] != 100:
			placer += Vector2(1,0)
			set_cell(placer.x,placer.y,chunk[i])
		elif chunk[i] == 100:
			placer = (start_pos + Vector2(0,1))
			set_cell(placer.x,placer.y,chunk[i])
	placer = start_pos
	
