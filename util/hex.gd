extends Object

class_name HexUtil

# (dq, dr, ds)
const cube_direction_vectors: Array[Vector3i] = [
	Vector3i(1, 0, -1), # E 0
	Vector3i(1, -1, 0), # NE 1
	Vector3i(0, -1, 1), # NW 2
	Vector3i(-1, 0, 1), # W 3 
	Vector3i(-1, 1, 0), # SW 4
	Vector3i(0, 1, -1)  # SE 5
]

static func hex_in_bounds(pos: Vector2i, map_size: int) -> bool:
	return pos.x > -1 and pos.x < map_size and pos.y > -1 and pos.y < map_size

static func cube_neighbor(cube: Vector3i, direction: int) -> Vector3i:
		return cube + cube_direction_vectors[direction]

static func hex_in_direction(pos: Vector2i, direction: int, distance: int) -> Vector2i:
	var cube_pos = offset_to_cube(pos)
	var target_hex = cube_pos + (cube_direction_vectors[direction] * distance)
	return cube_to_offset(target_hex)

static func get_neighbors(pos: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	for i in range(6):
		neighbors.append(hex_in_direction(pos, i, 1))
	return neighbors

static func offset_to_cube(pos: Vector2i) -> Vector3i:
	var q = pos.x - (pos.y - (pos.y & 1)) / 2
	var r = pos.y
	var s = -q - r
	return Vector3i(q, r, s)

func test_offset_to_cube():
	var actual = offset_to_cube(Vector2i(0, 0))
	var expected = Vector3i(0, 0, 0)
	assert(actual == expected, "%s == %s" % [actual, expected])
	
	var actual1 = offset_to_cube(Vector2i(0, 1))
	var expected1 = Vector3i(0, 1, -1)
	assert(actual1 == expected1, "%s == %s" % [actual1, expected1])

static func cube_to_offset(pos: Vector3i) -> Vector2i:
	var col = pos.x + (pos.y - (pos.y & 1)) / 2
	var row = pos.y
	return Vector2i(col, row)

static func get_hex_ring(pos: Vector2i, radius: int) -> Array[Vector2i]:
	if radius == 0:
		return [pos]
	var cube_pos = offset_to_cube(pos)
	var results: Array[Vector2i] = []
	var hex: Vector2i = hex_in_direction(pos, 4, radius)
	for i in range(6):
		for j in range(radius):
			results.append(hex)
			hex = hex_in_direction(hex, i, 1)
	return results

func test_get_hex_ring():
	var actual = get_hex_ring(Vector2i(10, 10), 1)
	var expected = [
		Vector2i(1,2),
		Vector2i(2,2),
		Vector2i(2,1),
		Vector2i(2,0),
		Vector2i(1,0),
		Vector2i(0,1)
	]
	assert(actual == expected, "%s == %s" % [actual, expected])

static func hex_distance(h1: Vector2i, h2: Vector2i) -> int:
	var vec = offset_to_cube(h1) - offset_to_cube(h2)
	return (abs(vec.x) + abs(vec.y) + abs(vec.z)) / 2

static func hex_to_pixel_center(pos: Vector2i, hex_width_px: int, hex_height_px: int) -> Vector2i:
	var cube_coords = offset_to_cube(pos)
	var size = hex_width_px / 2
	var x = size * (2 * cube_coords.x + cube_coords.y)
	var y = size * (1.5 * cube_coords.y)
	return Vector2(x, y)
