extends Resource

class_name Polity

var rng: RandomNumberGenerator

# State and signals

signal pop_changed(new_pop: int)

var population: int = 20:
	set(value):
		population = value
		pop_changed.emit(value)

signal starvation_level_changed(new_sl: int)

var starvation_level: int = 0:
	set(value):
		starvation_level = value
		starvation_level_changed.emit(value)

var labor_per_pop_per_day = 1

signal available_labor_changed(new_value: int)

var available_labor: int = 0:
	set(value):
		available_labor = value
		available_labor_changed.emit(value)

signal available_tasks_changed(new_value: Dictionary)

# Task ID -> maximum allocation
var available_tasks = {}:
	set(value):
		available_tasks = value
		available_tasks_changed.emit(value)

var task_labor_allocation = {}

# Units?
var position: Vector2i
var stockpile: Stockpile

# Functions

func _init(start_position: Vector2i):
	rng = RandomNumberGenerator.new()
	position = start_position
	stockpile = Stockpile.new()

func tick(world: World):
	if population > 0:
		# gather food first
		available_labor = labor_per_pop_per_day * population
		var resources_in_range = world.resources_in_range(position, 1)
		update_available_tasks(resources_in_range)
		print(available_tasks)
		consume_food()
		starvation_dieoff()

func update_available_tasks(resources_in_range: Dictionary):
	var new_available_tasks = {}
	for task_id in GameConfig.all_task_ids():
		var required_resource = GameConfig.get_task_required_resource(task_id)
		if resources_in_range.has(required_resource):
			var num_resources = resources_in_range[required_resource]
			var labor_assignable_to_task = num_resources * GameConfig.get_task_maximum_labor_per_resource(task_id)
			new_available_tasks[task_id] = labor_assignable_to_task
	available_tasks = new_available_tasks

func consume_food():
	var total_food = stockpile.get_total_food()
	stockpile.consume_food_for_pop(population)
	var deficit = float(total_food - population) / float(population)
	if deficit < 0:
		starvation_level += floor(-deficit * 10)
	else:
		starvation_level = 0

func starvation_dieoff():
	var starvation_over_critical = starvation_level - 100
	if starvation_over_critical > 0:
		var dieoff_factor = float(starvation_over_critical) / 100
		var variance = rng.randf_range(0.0, 0.05)
		var starvation_deaths = floor(population * (dieoff_factor + variance))
		print("starvation_over_critical %s, dieoff_factor %s, variance %s, starvation_deaths %s" % [
			starvation_over_critical,
			dieoff_factor,
			variance,
			starvation_deaths
		])
		population = max(population - starvation_deaths, 0)
