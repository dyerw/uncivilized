extends Node2D

var grass_tiles = [
	preload("res://assets/tiles/hexPlains00.png"),
	preload("res://assets/tiles/hexPlains01.png"),
	preload("res://assets/tiles/hexPlains02.png"),
	preload("res://assets/tiles/hexPlains03.png")
]

var shrub_tiles = [
	preload("res://assets/tiles/hexScrublands00.png"),
	preload("res://assets/tiles/hexScrublands01.png"),
	preload("res://assets/tiles/hexScrublands02.png"),
	preload("res://assets/tiles/hexScrublands03.png")
]

var mountains = [
	preload("res://assets/tiles/hexMountain00.png"),
	preload("res://assets/tiles/hexMountain01.png"),
	preload("res://assets/tiles/hexMountain03.png")
]

func texture_for_tile(tile: TerrainGen.Tile):
	match tile:
		TerrainGen.Tile.DEEP_WATER:
			return preload("res://assets/tiles/hexOcean00.png")
		TerrainGen.Tile.SHALLOW_WATER:
			return preload("res://assets/tiles/hexOcean01.png")
		TerrainGen.Tile.GRASS:
			return grass_tiles.pick_random()
		TerrainGen.Tile.SHRUBS:
			return shrub_tiles.pick_random()
		TerrainGen.Tile.ROCKY:
			return mountains.pick_random()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func draw_tiles(tile_map: Array):
	var size = tile_map.size()
	for x in range(size):
		for y in range(size):
			draw_hex(Vector2i(x, y), tile_map[x][y])

func draw_hex(offset_coord: Vector2i, tile: TerrainGen.Tile):
	var sprite = Sprite2D.new()
	sprite.texture = texture_for_tile(tile)
	add_child(sprite)
	sprite.z_index = offset_coord.y
	sprite.position = HexUtil.hex_to_pixel_center(offset_coord, 256, 256)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
