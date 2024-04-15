extends Resource

class_name Polity

var rng: RandomNumberGenerator

signal pop_changed(new_pop: int)

var population: int = 100:
	set(value):
		population = value
		pop_changed.emit(value)

signal starvation_level_changed(new_sl: int)

var starvation_level: int = 0:
	set(value):
		starvation_level = value
		starvation_level_changed.emit(value)

# Units?
var position: Vector2i
var stockpile: Stockpile

func _init(start_position: Vector2i):
	rng = RandomNumberGenerator.new()
	position = start_position
	stockpile = Stockpile.new()

func tick():
	if population > 0:
		# gather food first
		consume_food()
		starvation_dieoff()

func consume_food():
	var total_food = stockpile.get_total_food()
	stockpile.consume_food_for_pop(population)
	var deficit = float(total_food - population) / float(population)
	print("deficit %s" % deficit)
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
