extends Node2D

const MAP_SIZE = 100


@onready var rng = RandomNumberGenerator.new()

# Child Nodes
@onready var map_node: Node2D = $Map
@onready var flora_overlay: Node2D = $FloraLayer
@onready var unit_layer: Node2D = $UnitLayer
@onready var camera: Camera2D = $Camera2D

@export var time_label: Label
@export var pop_label: Label
@export var starvation_level_label: Label

# Time State
enum { SPRING, SUMMER, FALL, WINTER }
var season = SPRING
var day = 0

# Flora state
var wheat_map = TerrainGen.filled_2d_array(MAP_SIZE, 0)

# Polity state
var player_polity: Polity = null

# Map Gen State
var highest_elevation = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	var height_map = TerrainGen.generate_noise_height_map(MAP_SIZE)
	highest_elevation = TerrainGen.get_max_height_from_height_map(height_map)
	var tiles = TerrainGen.derive_tile_from_height_map(height_map)
	
	map_node.draw_tiles(tiles)
	generate_wheat(tiles)
	flora_overlay.place_flora_icons(wheat_map)
	
	var start_position = find_start_position(tiles)
	player_polity = Polity.new(start_position)
	
	# Hook up UI signals
	pop_label.text = str(player_polity.population)
	player_polity.connect("pop_changed", func (value): pop_label.text = str(value))
	player_polity.connect("starvation_level_changed", func (value): starvation_level_label.text = str(value))
	
	unit_layer.draw_polity(player_polity)
	camera.position = HexUtil.hex_to_pixel_center(start_position, 256, 256)

func find_start_position(tile_map: Array):
	var start_pos = Vector2i(MAP_SIZE / 2, MAP_SIZE / 2)
	while tile_map[start_pos.x][start_pos.y] != TerrainGen.Tile.GRASS:
		start_pos = HexUtil.hex_in_direction(start_pos, rng.randi_range(0, 5), 2)
	return start_pos

func generate_wheat(tile_map: Array):
	var size = tile_map.size()
	for x in range(size):
		for y in range(size):
			if tile_map[x][y] == TerrainGen.Tile.GRASS:
				if rng.randi_range(0, 10) < 2:
					wheat_map[x][y] = 1

func update_time_label():
	var season_text = "Spring"
	match season:
		SUMMER:
			season_text = "Summer"
		FALL:
			season_text = "Fall"
		WINTER:
			season_text = "Winter"
	var label_text = "%s %s" % [season_text, day]
	time_label.text = label_text

func tick_time():
	day = (day + 1) % 90
	if day == 0:
		season = (season + 1) % 3

func tick_fauna():
	pass

func _on_tick_timer_timeout():
	tick_time()
	update_time_label()
	player_polity.tick()
	#tick_fauna()
	#tick_flora()

const PLATE_COLORS = [
	Color.AQUAMARINE,
	Color.BROWN,
	Color.CHARTREUSE,
	Color.CORNFLOWER_BLUE,
	Color.DARK_GOLDENROD,
	Color.DARK_TURQUOISE,
	Color.DARK_SLATE_BLUE
]

func add_tectonic_plates_hexagon_overlay(pos: Vector2i, plate_idx: int):
	draw_hexagon(pos, PLATE_COLORS[plate_idx])

func add_height_hexagon_overlay(pos: Vector2i, height: int):
	var color_weight = float(height) / float(highest_elevation)
	var color = Color.GREEN_YELLOW.lerp(Color.RED, color_weight)
	if height < 10:
		color = Color.AQUA
	if height < 7:
		color = Color.DARK_CYAN
	draw_hexagon(pos, color)


func draw_hexagon(pos: Vector2i, color: Color):
	var polygon_points = PackedVector2Array()
	var center = Vector2i(0, 0) # tile_map.map_to_local(pos)
	for i in range(6):
		var translation = Vector2(0, 32).rotated(deg_to_rad(60) * i)
		polygon_points.append(translation)
	var polygon_node = Polygon2D.new()
	polygon_node.polygon = polygon_points
	polygon_node.color = color
	add_child(polygon_node)
	polygon_node.position = center
