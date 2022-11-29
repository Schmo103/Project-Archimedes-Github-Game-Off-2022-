extends TileMap

var fireball = preload("res://fireball.tscn")
export var chunk_num = 10
export var max_x_dist = 6
export var max_y_dist = 3
var test_chunk = [12,11,2,100,8,9,10]
var test_chunk2 = [12,2,100,8,10]
var chunk3 =  [12, 3, 100, 4, 5, 3, 100, 4, 5, 5, 3, 100, 4, 5, 5, 5, 3]
var chunk1 =    [3, 101, 101, 101, 101, 7, 100, 4, 3, 101, 101, 7, 6, 100, 4, 5, 3, 7, 5, 6, 5]
var jump_min = Vector2(0, 1)
var jump_max = Vector2(4, 4)
var builder = Vector2(7, 8)

#var en1 =  [ Vector2(205, 44), Vector2(55, 42), Vector2(14, 12)]
export var placer = Vector2(11,9)
var direction = 1 #1 is right, -1 is left
var ready = true
#onready var time = $Timer
var choice
# 0 = start tile, 1 = 
var tile_pos_list = [-2,-1]
var first_tile_placement = true

var origin = Vector2(-40, -50)
var size = Vector2(100, 100)
var player_tile = Vector2(10, 9)
onready var terrain = get_node(".")
onready var world = get_parent()
onready var rob = RandomNumberGenerator.new()
var flag = 0


		
func launch_pad():
	var x = player_tile.x - 2
	while(x < player_tile.x + 2):
		set_cell(x, player_tile.y, 5)
		x += 1

	
class prefab:
	
	var land : Array
	var terrain
	var world
	var enemy
	var size_mod : Vector2
	var size_of : Vector2
	
	func _init(l, s, terr, w, enem):
		self.land = l
		self.terrain = terr
		self.world = w
		self.enemy = enem
		self.size_mod = s
		dimensions()
		
	func dimensions():
		var segs : Array = []
		var row  : Array = []
		var leng_x = 0
		var leng_y = 0
		var j = 0
		for g in land:
			j += 1
			if g != 100 and j != land.size():
				row.append(g)
			else:
				if j == land.size():
					row.append(g)
				segs.append(row)
				if row.size() > leng_x:
					leng_x = row.size()
				row = []
		leng_y = segs.size()
		size_of = Vector2(leng_x, leng_y) + size_mod
#		prints("sizeof:", size_of)

		
	func draw(pos):
#		prints("initial pos:", str(pos))
		pos = pos - size_of + size_mod + Vector2(1, 1)
#		prints("offset:", str(Vector2(1, 1) - size_of))
		var brg = pos
		var en
		var enz : Array = []
		var start_pos = pos
#		prints("pos:", str(pos))
#		prints("brg:", str(brg))
		for i in land.size():
			if land[i] == 100:
				start_pos += Vector2(0,1)
				pos = start_pos 
			elif land[i] == 101:
				pos += Vector2(1,0)
			elif land[i] == 102:
				enz.append(pos * 32 + Vector2(16, 16))
#				prints("v:", str(pos * 32 + Vector2(16, 16)))
				pos += Vector2(1,0)
			else: 
				terrain.set_cell(pos.x, pos.y, land[i])
				pos += Vector2(1,0)
		var ppos = brg * 32
#		prints("ppos:", ppos)
		for v in enz:
			en = enemy.instance()
			en.position = v
#			prints("final pos:", str(ppos + v))
			world.add_child(en)
			
	func draw_left(p):
		p.x = p.x + size_of.x + size_mod.x - 2
		draw(p)



#prefabs declared
onready var jump = prefab.new([12, 11, 2, 100, 100, 101, 101, 101, 101, 101, 101, 101, 102, 100, 101, 101, 101, 101, 101, 101, 12, 11, 2], Vector2(0, 0), terrain, world, fireball)
onready var prefab1 = prefab.new(chunk1, Vector2(0, 0), terrain, world, fireball)

onready var basic_plat1 = prefab.new(test_chunk, Vector2(0, 0), terrain, world, fireball)
onready var basic_plat2r = prefab.new( [12, 3, 100, 4, 5, 3, 100, 4, 5, 5, 11, 2, 100, 8, 9, 9, 9, 10], Vector2(0, 0), terrain, world, fireball)
onready var basic_plat2l = prefab.new( [101, 101, 101, 7, 2, 100, 101, 101, 7, 5, 6, 100, 12, 11, 5, 11, 6, 100, 8, 9, 9, 9, 10], Vector2(0, 0), terrain, world, fireball)
onready var en1 = prefab.new( [101, 102, 100, 12, 11, 2, 100, 8, 9, 10], Vector2(0, -1), terrain, world, fireball)
onready var en2 = prefab.new( [101, 101, 101, 102, 100, 12, 11, 11, 11, 11, 2, 100, 8, 9, 9, 9, 9, 10], Vector2(0, -1), terrain, world, fireball)
onready var switch1r = prefab.new( [ 101, 101, 101, 12, 11, 2, 100, 101, 101, 101, 8, 9, 9, 100, 100, 12, 2, 100, 8, 10, 100, 101, 101, 101, 12, 11, 2, 100, 101, 101, 101, 8, 9, 10], Vector2(0, 0), terrain, world, fireball)
onready var switch1l = prefab.new( [12, 11, 2, 100, 8, 9, 9, 100, 100, 101, 101, 101, 101, 12, 2, 100, 101, 101, 101, 101, 10, 10, 100, 12, 11, 2, 100, 8, 9, 9], Vector2(0, 0), terrain, world, fireball)
onready var switch2r = prefab.new([101, 101, 101, 101, 101, 101, 12, 2, 100, 101, 101, 101, 101, 101, 101, 8, 10, 100, 12, 11, 2, 100, 8, 9, 10, 100, 101, 101, 101, 101, 101, 12, 3, 100, 101, 101, 101, 101, 101, 4, 5, 3, 100, 101, 101, 101, 101, 101, 8, 9, 10], Vector2(0, 0), terrain, world, fireball)
onready var switch2l = prefab.new( [12, 2, 100, 8, 10, 100, 101, 101, 101, 101, 101, 12, 11, 2, 100, 101, 101, 101, 101, 101, 8, 10, 10, 100, 101, 7, 2, 100, 7, 5, 6, 100, 8, 10, 10], Vector2(0, 0), terrain, world, fireball)

var first_e : int = 2
var first_s : int = 4
onready var left_prefabs : Array = [basic_plat1, basic_plat2l, en1, en2, switch1l, switch2l]
onready var right_prefabs : Array = [basic_plat1, basic_plat2r, en1, en2, switch1r, switch2r]
var array_len : int
func _ready():
#	prints("size of en2", str(en2.size_of))
	array_len = left_prefabs.size()
	rob.randomize()
	clear()
	launch_pad() 
	pass

	
func _on_World_ready():
	generate_chunck()
	generate_chunck()
	#generate_chunck()
	flag = -32 * 32
	
func generate_chunck():
	#var builder_real = builder * 32
	var block : prefab
	var num : int
	var end : int = builder.y - 32
	while(!(builder.y < end)):
		if direction == 1:
			#choose prefab
			num = rob.randi() % array_len
			block = right_prefabs[num]
			#draw prefab
			block.draw(builder)
			if num >= first_s:
				direction = -1
				builder -= Vector2(direction * 2, block.size_of.y)
			else:
				builder -= block.size_of 
		else:
			num = rob.randi() % array_len
			block = left_prefabs[num]
			#draw prefab
			block.draw_left(builder)
			if num >= first_s:
				direction = 1
				builder -= Vector2(direction * 2, block.size_of.y)
			else:
				builder -= Vector2(-block.size_of.x, block.size_of.y)
		#add jump
		#builder -= Vector2(1, 1)
	flag = flag - (32- (end - builder.y)) * 32
		
		
var con = 0
func flag_passed():
	prints(con, ": new chunk")
	con += 1
	generate_chunck()
		
	
	
	
	
	
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
	


