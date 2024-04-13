extends Node2D

const MAP_SIZE = 100

@onready var time_label: Label = $Control/PanelContainer/TimeLabel
@onready var rng = RandomNumberGenerator.new()
@onready var map_node: Node2D = $Map

var wheat_resource_scn = preload("res://wheat_resource.tscn")
var fauna_buffalo_scn = preload("res://fauna_buffalo.tscn")

# Time State
enum { SPRING, SUMMER, FALL, WINTER }
var season = SPRING
var day = 0

# Fauna state
var buffalo_nodes = []

# Flora state
var wheat_nodes = []

# Map Gen State
var highest_elevation = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_wheat(Vector2i(1,1))
	spawn_buffalo(Vector2i(2,2))
	spawn_buffalo(Vector2i(3,4))
	
	#var height_map = TerrainGen.generate_topography(MAP_SIZE, 2, 10)
	#print(highest_elevation)
	#
	#var plate_map = TerrainGen.generate_tectonic_plates(MAP_SIZE, 6)
	#for x in range(MAP_SIZE):
		#for y in range(MAP_SIZE):
			#add_tectonic_plates_hexagon_overlay(Vector2i(x, y), plate_map[x][y])
	
	var height_map = TerrainGen.generate_noise_height_map(MAP_SIZE)
	highest_elevation = TerrainGen.get_max_height_from_height_map(height_map)
	var tiles = TerrainGen.derive_tile_from_height_map(height_map)
	
	map_node.draw_tiles(tiles)
	
	#print(highest_elevation)
	#for x in range(MAP_SIZE):
		#for y in range(MAP_SIZE):
			#add_height_hexagon_overlay(Vector2i(x, y), height_map[x][y])

const MIN_PEAK_HEIGHT: int = 7
const MAX_PEAK_HEIGHT: int = 15

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

func spawn_wheat(pos: Vector2i):
	var wheat = wheat_resource_scn.instantiate()
	wheat_nodes.append(wheat)

func spawn_buffalo(pos: Vector2i):
	var buffalo = fauna_buffalo_scn.instantiate()
	buffalo_nodes.append(buffalo)

func tick_time():
	day = (day + 1) % 90
	if day == 0:
		season = (season + 1) % 3

func tick_fauna():
	pass

func tick_flora():
	for w in wheat_nodes:
		print("tick wheat")

func _on_tick_timer_timeout():
	tick_time()
	update_time_label()
	tick_fauna()
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
