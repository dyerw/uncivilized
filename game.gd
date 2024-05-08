extends Node2D

const MAP_SIZE = 100


@onready var rng = RandomNumberGenerator.new()

# Child Nodes
@onready var map_node: Node2D = $Map

@onready var camera: Camera2D = $Camera2D

@export var resource_layer: Node2D
@export var time_label: Label
@export var pop_label: Label
@export var starvation_level_label: Label

# Time State
enum { SPRING, SUMMER, FALL, WINTER }
var season = SPRING
var day = 0

# Polity state
var player_polity: Polity = null

@onready var world: World = World.new(MAP_SIZE)

# Called when the node enters the scene tree for the first time.
func _ready():
	world.generate_area()
	map_node.draw_tiles(world.tiles)
	resource_layer.draw_resource_icons(world.resource_locations)
	
	var start_position = find_start_position(world.tiles)
	player_polity = Polity.new(start_position)
	$UnitLayer.draw_polity(player_polity)
	
	$UI.connect_polity_signals(player_polity)
	
	# Hook up UI signals
	pop_label.text = str(player_polity.population)
	player_polity.connect("pop_changed", func (value): pop_label.text = str(value))
	player_polity.connect("starvation_level_changed", func (value): starvation_level_label.text = str(value))
	player_polity.connect("moving_to_hex", func (pos, ticks): $UnitLayer.move_polity(pos, ticks))
	
	$InputHandler.connect('player_move', _on_player_move_polity)
	
	camera.position = HexUtil.hex_to_pixel_center(start_position)
	print(start_position)

func find_start_position(tile_map: Array):
	var start_pos = Vector2i(MAP_SIZE / 2, MAP_SIZE / 2)
	while tile_map[start_pos.x][start_pos.y] != TerrainGen.Tile.GRASS:
		start_pos = HexUtil.hex_in_direction(start_pos, rng.randi_range(0, 5), 2)
	return start_pos

# TODO: This needs to be moved over to the UI stuff
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

func _on_tick_timer_timeout():
	tick_time()
	update_time_label()
	player_polity.tick(world)

# Player Inputs
func _on_player_move_polity(pos: Vector2i):
	print("player request move to %s" % pos)
	if HexUtil.hex_distance(player_polity.position, pos) > 1:
		print("too far!")
		return
	player_polity.set_movement_path([pos])
