extends Object

class_name TerrainGen

static func filled_2d_array(size: int, value):
	var a = []
	for x in range(size):
		a.append([])
		for y in range(size):
			a[x].append(value)
	return a

# assumes square
static func get_max_height_from_height_map(height_map: Array):
	var size = height_map.size()
	var max_height = 0
	for x in range(size):
		for y in range(size):
			if height_map[x][y] > max_height:
				max_height = height_map[x][y]
	return max_height

# Array[Array[Int]], thank you GDScript
static func generate_topography(map_size: int, min_peak_height: int, max_peak_height: int):
	var rng = RandomNumberGenerator.new()
	
	# Initialize topographical map at sea level
	var height_map = filled_2d_array(map_size, 0)

	for i in range(5):
		var direction = rng.randi_range(0, 5)
		var path = get_wandering_hex_path(direction, map_size)
		for path_hex in path:
			if rng.randi_range(0, 10) < 8:
				var peak_hex = HexUtil.hex_in_direction(path_hex, rng.randi_range(0, 5), rng.randi_range(5, 20))
				# Determine peak height
				var peak_height = rng.randi_range(min_peak_height, max_peak_height)
				if i > 2:
					peak_height = floor(peak_height / 2)
				
				raise_peak(peak_hex, peak_height, height_map, map_size)
	return height_map

static func raise_peak(peak_hex, peak_height, height_map, map_size: int):
	for radius in range(peak_height):
		var ring_hexes = HexUtil.get_hex_ring(Vector2i(peak_hex.x, peak_hex.y), radius)
		for hex in ring_hexes:
			if HexUtil.hex_in_bounds(hex, map_size):
				height_map[hex.x][hex.y] += peak_height - radius
				var height = height_map[hex.x][hex.y]

static func get_wandering_hex_path(direction: int, map_size: int):
	var rng = RandomNumberGenerator.new()
	var current_hex = null
	if direction == 0:
		current_hex = Vector2i(0, rng.randi_range(0, map_size))
	elif direction == 1 or direction == 2:
		current_hex = Vector2i(rng.randi_range(0, map_size), map_size - 1)
	elif direction == 3:
		current_hex = Vector2i(map_size - 1, rng.randi_range(0, map_size))
	else:
		current_hex = Vector2i(rng.randi_range(0, map_size), 0)

	var path = []
	var current_direction = direction
	while HexUtil.hex_in_bounds(current_hex, map_size):
		path.append(current_hex)
		var wander_roll = rng.randi_range(0, 10)
		if wander_roll < 7:
			current_hex = HexUtil.hex_in_direction(current_hex, direction, 1)
		elif wander_roll < 9:
			current_hex = HexUtil.hex_in_direction(current_hex, (direction + 1) % 6, 1)
			current_direction = (direction + 1) % 6
		else:
			var x = direction - 1
			if direction < 0:
				x = 5
			current_direction = x
			current_hex = HexUtil.hex_in_direction(current_hex, x, 1)
	return path

const MAX_HEIGHT = 50
const RIVER_SPAWN_THRESHOLD = 0.8

static func generate_noise_height_map(map_size: int):
	var rng = RandomNumberGenerator.new()
	var fnl = FastNoiseLite.new()
	fnl.seed = rng.randi()
	fnl.noise_type = FastNoiseLite.TYPE_PERLIN
	fnl.frequency = 0.03
	fnl.fractal_type = FastNoiseLite.FRACTAL_FBM
	fnl.fractal_octaves = 3
	
	var height_map = filled_2d_array(map_size, 0)
	for x in range(map_size):
		for y in range(map_size):
			# change the domain from [-1, 1] -> [0, 1]
			var normalized_noise = (fnl.get_noise_2d(x, y) + 1) / 2
			var flattened_noise = pow(normalized_noise, 2)
			height_map[x][y] = flattened_noise * 50
	return height_map

enum Tile {
	DEEP_WATER,
	SHALLOW_WATER,
	GRASS,
	SHRUBS,
	ROCKY
}

static func derive_tile_from_height_map(height_map: Array):
	var tiles = filled_2d_array(height_map.size(), 0)
	for x in range(height_map.size()):
		for y in range(height_map.size()):
			var height = height_map[x][y]
			if height < 8:
				tiles[x][y] = Tile.DEEP_WATER
			elif height < 10:
				tiles[x][y] = Tile.SHALLOW_WATER
			elif height < 20:
				tiles[x][y] = Tile.GRASS
			elif height < 25:
				tiles[x][y] = Tile.SHRUBS
			else:
				tiles[x][y] = Tile.ROCKY
	return tiles

# "Tectonic plates" are Voronoi polygons basically
static func generate_tectonic_plates(map_size: int, num_plates: int):
	var rng = RandomNumberGenerator.new()
	
	var plate_map = []
	for x in range(map_size):
		plate_map.append([])
		for y in range(map_size):
			plate_map[x].append(99)
	
	var plate_centers: Array[Vector2i] = []
	for i in range(num_plates):
		var x = rng.randi_range(0, map_size)
		var y = rng.randi_range(0, map_size)
		plate_centers.append(Vector2i(x, y))

	for x in range(map_size):
		for y in range(map_size):
			var min_distance = 9999999
			var plate_idx = 99
			for i in range(num_plates):
				var plate_center = plate_centers[i]
				var distance = HexUtil.hex_distance(Vector2i(x, y), plate_center)
				if distance < min_distance:
					min_distance = distance
					plate_idx = i
			plate_map[x][y] = plate_idx
	return plate_map
