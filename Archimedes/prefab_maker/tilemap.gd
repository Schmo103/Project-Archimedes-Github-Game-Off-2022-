extends TileMap
var origen = Vector2(0, 0)
var size = Vector2(50, 50)

var tiles = []
var enemies = []
var row = []

var tile
func _ready():
	for y in range(size.x):
		row = []
		for x in range(size.y):
			tile = get_cell(x + origen.x, y + origen.y)
			if tile == -1:
				row.append(101)
			elif tile == 0:
				row.append(102)
			else:
				row.append(tile)
		while(row.size() > 0 and row[row.size() - 1] == 101):
				row.remove(row.size() - 1)
		row.append(100)
		tiles.append_array(row)
	while(tiles.size() > 0 and tiles[tiles.size() - 1] == 100):
		tiles.remove(tiles.size() - 1)
	prints("tiles:", str(tiles))

