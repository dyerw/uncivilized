extends CanvasLayer

@export var available_daily_labor: Label
@export var labor_allocators_container: VBoxContainer

@onready var task_allocator_scn = preload("res://ui/custom_nodes/TaskAllocator.tscn")

var task_nodes = {}

signal task_allocation_changed(task_id: String, amount: int)

func _ready():
	for task_id in GameConfig.all_task_ids():
		var task_allocator = task_allocator_scn.instantiate()
		task_allocator.init_with_task(task_id, 0)
		labor_allocators_container.add_child(task_allocator)
		task_nodes[task_id] = task_allocator
		task_allocator.connect("task_allocation_increased", _on_task_allocator_increased)
		task_allocator.connect("task_allocation_decreased", _on_task_allocator_decreased)

func _on_task_allocator_decreased(task_id: String):
	task_allocation_changed.emit(task_id, -1)

func _on_task_allocator_increased(task_id: String):
	task_allocation_changed.emit(task_id, 1)

func connect_polity_signals(player_polity: Polity):
	# Signals from polity to UI
	player_polity.connect("available_labor_changed", func (value): available_daily_labor.text = str(value))
	player_polity.connect("available_tasks_changed", _on_available_tasks_changed)
	player_polity.connect("task_labor_allocation_changed", _on_task_labor_allocation_changed)
	
	# UI Signals back to polity
	self.connect("task_allocation_changed", player_polity._on_task_allocation_changed)

func _on_available_tasks_changed(available_tasks: Dictionary):
	for task_id in GameConfig.all_task_ids():
		var task_node: Control = task_nodes[task_id]
		if available_tasks.has(task_id):
			task_node.max_labor = available_tasks[task_id]
			task_node.show()
		else:
			task_node.hide()

func _on_task_labor_allocation_changed(task_id: String, labor: int):
	task_nodes[task_id].current_labor = labor

func _on_labor_overview_button_pressed():
	print("Hello button")
