extends Node2D

const MAP_SIZE = 100

@onready var tile_map: TileMap = $TileMap
@onready var time_label: Label = $Control/PanelContainer/TimeLabel
@onready var rng = RandomNumberGenerator.new()

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
	
	var height_map = TerrainGen.generate_topography(MAP_SIZE, 2, 10)
	print(highest_elevation)
	
	var plate_map = TerrainGen.generate_tectonic_plates(MAP_SIZE, 6)
	for x in range(MAP_SIZE):
		for y in range(MAP_SIZE):
			add_tectonic_plates_hexagon_overlay(Vector2i(x, y), plate_map[x][y])
	
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
	tile_map.add_child(wheat)
	wheat.position = tile_map.map_to_local(pos)

func spawn_buffalo(pos: Vector2i):
	var buffalo = fauna_buffalo_scn.instantiate()
	buffalo_nodes.append(buffalo)
	tile_map.add_child(buffalo)
	buffalo.position = tile_map.map_to_local(pos)

func tick_time():
	day = (day + 1) % 90
	if day == 0:
		season = (season + 1) % 3

func tick_fauna():
	for b in buffalo_nodes:
		if rng.randi_range(0, 1) == 0:
			var curr_coords = tile_map.local_to_map(b.position)
			var neighbors: Array[Vector2i] = HexUtil.get_neighbors(curr_coords)
			var new_coord = neighbors[rng.randi_range(0, neighbors.size() - 1)]
			b.position = tile_map.map_to_local(new_coord)

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
		color = Color.DARK_CYAN
	elif height < 20:
		color = Color.AQUA
	draw_hexagon(pos, color)


func draw_hexagon(pos: Vector2i, color: Color):
	var polygon_points = PackedVector2Array()
	var center = tile_map.map_to_local(pos)
	for i in range(6):
		var translation = Vector2(0, 32).rotated(deg_to_rad(60) * i)
		polygon_points.append(translation)
	var polygon_node = Polygon2D.new()
	polygon_node.polygon = polygon_points
	polygon_node.color = color
	add_child(polygon_node)
	polygon_node.position = center
