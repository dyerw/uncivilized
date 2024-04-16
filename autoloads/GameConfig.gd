extends Node

const HEX_HEIGHT: int = 256
const HEX_WIDTH: int = 256

var resources = {}

# Resource Config Keys
const MAXIMUM_ELEVATION = "maximum_elevation"
const OCCURENCE = "occurence"
const DISPLAY_NAME = "display_name"
const MAXIMUM_WATER_DISTANCE = "maximum_water_distance"
const MAXIMUM_LAND_DISTANCE = "maximum_land_distance"
const ICON_PATH = "icon_path"

func _ready():
	var resources_config = ConfigFile.new()
	var err = resources_config.load("res://data/resources.cfg")
	if err != OK:
		return
	
	for resource_id in resources_config.get_sections():
		var resource_dict = {}
		
		# Every resource has these
		resource_dict[DISPLAY_NAME] = resources_config.get_value(resource_id, DISPLAY_NAME)
		resource_dict[OCCURENCE] = resources_config.get_value(resource_id, OCCURENCE)
		resource_dict[ICON_PATH] = resources_config.get_value(resource_id, ICON_PATH)
		
		# Only some resources have these
		var maximum_elevation = resources_config.get_value(resource_id, MAXIMUM_ELEVATION)
		if maximum_elevation != null:
			resource_dict[MAXIMUM_ELEVATION] = maximum_elevation
		
		var maximum_water_distance = resources_config.get_value(resource_id, MAXIMUM_WATER_DISTANCE)
		if maximum_water_distance != null:
			resource_dict[MAXIMUM_WATER_DISTANCE] = maximum_water_distance
		
		var maximum_land_distance = resources_config.get_value(resource_id, MAXIMUM_LAND_DISTANCE)
		if maximum_land_distance != null:
			resource_dict[MAXIMUM_LAND_DISTANCE] = maximum_land_distance
		
		resources[resource_id] = resource_dict

func resource_has_key(resource_id: String, key: String):
	return resources[resource_id].has(key)

func get_resource_value(resource_id: String, key: String):
	var value = resources[resource_id][key]
	assert(value != null, "Attempted to get null value from GameConfig")
	return value

func all_resource_ids() -> Array:
	return resources.keys()
