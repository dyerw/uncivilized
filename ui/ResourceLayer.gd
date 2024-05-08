extends Node2D

# Vector2i -> Node
var resource_icon_nodes = {}

@onready var resource_icons_scn = preload("res://ui/HexResourceIcons.tscn")

# Dict is resource_id -> Array[Vector2i]
func draw_resource_icons(resources: Dictionary):
	for key in resources.keys():
		for pos in resources[key]:
			var resource_icon_node: Node2D
			if not resource_icon_nodes.has(pos):
				resource_icon_node = resource_icons_scn.instantiate()
				add_child(resource_icon_node)
				resource_icon_nodes[pos] = resource_icon_node
				# FIXME: Find a better place for this offset
				resource_icon_node.position = HexUtil.hex_to_pixel_center(pos)
			else:
				resource_icon_node = resource_icon_nodes[pos]
			resource_icon_node.add_resource(key)
