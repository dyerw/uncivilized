extends TileMap

const MAP_SIZE = 200
const MAP_LAYER = 0
const MAP_TILE_SET_SOURCE_ID = 0

var tiles = {
	"grass": Vector2i(0, 0),
	"river": Vector2i(1, 0)
}

func set_map_tile(pos: Vector2i, tile: String):
	set_cell(MAP_LAYER, pos, MAP_TILE_SET_SOURCE_ID, tiles[tile])

# Called when the node enters the scene tree for the first time.
func _ready():
	# TESTS
	#test_offset_to_cube()
	#test_get_hex_ring()
	
	# Fill with sand
	for x in MAP_SIZE:
		for y in MAP_SIZE:
			set_map_tile(Vector2i(x, y), "grass")

	set_map_tile(Vector2i(10, 10), "river")

func _input(event):
	if event is InputEventMouseMotion:
		pass
