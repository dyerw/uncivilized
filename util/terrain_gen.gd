extends Object

class_name TerrainGen

# Array[Array[Int]], thank you GDScript
static func generate_topography(map_size: int, min_peak_height: int, max_peak_height: int):
	var rng = RandomNumberGenerator.new()
	
	# Initialize topographical map at sea level
	var height_map = []
	for x in range(map_size):
		height_map.append([])
		for y in range(map_size):
			height_map[x].append(0)

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
