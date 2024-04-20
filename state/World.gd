extends Object

class_name World

var rng: RandomNumberGenerator

var height_map: Array
var tiles: Array
var size = 0

# resource_id -> Array[Vector2]
var resource_locations = {}

func _init(initial_size: int):
	rng = RandomNumberGenerator.new()
	size = initial_size

# this is named this because i have half an idea that the map will be "infinite"
# and we'll do minecraft style chunk generation
func generate_area():
	height_map = TerrainGen.generate_noise_height_map(size)
	#highest_elevation = TerrainGen.get_max_height_from_height_map(height_map)
	tiles = TerrainGen.derive_tile_from_height_map(height_map)
	spawn_resources()

func spawn_resources():
	for x in range(size):
		for y in range(size):
			var pos = Vector2i(x, y)
			for resource_id in GameConfig.all_resource_ids():
				# is this x, y location able to spawn this resource?
				# defaults to true unless some constraint says otherwise
				var tile_is_spawnable = true
				
				if resource_id == "fish" and TerrainGen.is_water(tiles[x][y]):
					pass
				
				if GameConfig.resource_has_key(resource_id, GameConfig.MAXIMUM_ELEVATION):
					var maximum_elevation = GameConfig.get_resource_value(resource_id, GameConfig.MAXIMUM_ELEVATION)
					tile_is_spawnable = tile_is_spawnable and maximum_elevation_spawn_constraint_met(pos, maximum_elevation)
				
				if GameConfig.resource_has_key(resource_id, GameConfig.MAXIMUM_WATER_DISTANCE):
					var maximum_water_distance = GameConfig.get_resource_value(resource_id, GameConfig.MAXIMUM_WATER_DISTANCE)
					tile_is_spawnable = tile_is_spawnable and maximum_water_distance_constraint_met(pos, maximum_water_distance)
				
				if GameConfig.resource_has_key(resource_id, GameConfig.MAXIMUM_LAND_DISTANCE):
					var maximum_land_distance = GameConfig.get_resource_value(resource_id, GameConfig.MAXIMUM_LAND_DISTANCE)
					tile_is_spawnable = tile_is_spawnable and maximum_land_distance_constraint_met(pos, maximum_land_distance)
				
				if tile_is_spawnable:
					var occurence = GameConfig.get_resource_value(resource_id, GameConfig.OCCURENCE)
					var roll = rng.randf_range(0.0, 1.0)
					if roll < occurence:
						if not resource_locations.has(resource_id):
							resource_locations[resource_id] = [pos]
						else:
							resource_locations[resource_id].append(pos)

# returns resource id -> num in range
# FIXME: This is not efficient like at all
func resources_in_range(pos: Vector2i, r: int) -> Dictionary:
	var result = {}
	for hex in HexUtil.all_hexes_within(pos, r):
		for resource_id in resource_locations.keys():
			for p in resource_locations[resource_id]:
				if p == hex:
					if result.has(resource_id):
						result[resource_id] += 1
					else:
						result[resource_id] = 1
	return result

func maximum_elevation_spawn_constraint_met(pos: Vector2i, value: int):
	var elevation = height_map[pos.x][pos.y]
	return elevation <= value

func maximum_water_distance_constraint_met(pos: Vector2i, value: int):
	var tile_coords_in_range = HexUtil.all_hexes_within(pos, value)
	var water_present = false
	for c in tile_coords_in_range:
		if HexUtil.hex_in_bounds(c, size) and TerrainGen.is_water(tiles[c.x][c.y]):
			water_present = true
			break
	return water_present

func maximum_land_distance_constraint_met(pos: Vector2i, value: int):
	var tile_coords_in_range = HexUtil.all_hexes_within(pos, value)
	var land_present = false
	for c in tile_coords_in_range:
		if HexUtil.hex_in_bounds(c, size) and not TerrainGen.is_water(tiles[c.x][c.y]):
			land_present = true
			break
	return land_present
