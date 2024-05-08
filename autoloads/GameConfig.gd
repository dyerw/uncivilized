extends Node

const HEX_HEIGHT: int = 256
const HEX_WIDTH: int = 256

var resources = {}

@onready var tasks_config = ConfigFile.new()
@onready var goods_config = ConfigFile.new()


# Resource Config Keys
const MAXIMUM_ELEVATION = "maximum_elevation"
const OCCURENCE = "occurence"
const DISPLAY_NAME = "display_name"
const MAXIMUM_WATER_DISTANCE = "maximum_water_distance"
const MAXIMUM_LAND_DISTANCE = "maximum_land_distance"
const ICON_PATH = "icon_path"

func _ready():
	# TODO: This sucks, probably get this all into classes in mem
	load_resources_config()
	goods_config.load("res://data/goods.cfg")
	tasks_config.load("res://data/tasks.cfg")

func all_task_ids() -> PackedStringArray:
	return tasks_config.get_sections()

func get_task_required_resource(task_id: String) -> String:
	var required_resource = tasks_config.get_value(task_id, "required_resource")
	return required_resource

func get_task_maximum_labor_per_resource(task_id: String) -> int:
	var maximum_labor_per_resource = tasks_config.get_value(task_id, "maximum_labor_per_resource")
	return maximum_labor_per_resource

func get_task_display_name(task_id: String) -> String:
	return tasks_config.get_value(task_id, "display_name")

func get_task_output(task_id:String) -> Dictionary:
	var good = tasks_config.get_value(task_id, "output")
	var quantity = tasks_config.get_value(task_id, "output_quantity")
	return {
		good = good,
		quantity = quantity
	}

func load_resources_config():
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
