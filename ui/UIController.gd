extends CanvasLayer

@export var available_daily_labor: Label
@export var labor_allocators_container: VBoxContainer

@onready var task_allocator_scn = preload("res://ui/custom_nodes/TaskAllocator.tscn")

func connect_polity_signals(player_polity: Polity):
	player_polity.connect("available_labor_changed", func (value): available_daily_labor.text = str(value))
	player_polity.connect("available_tasks_changed", _on_available_tasks_changed)

func _on_available_tasks_changed(available_tasks: Dictionary):
	for n in labor_allocators_container.get_children():
		n.queue_free()
	for task_id in available_tasks.keys():
		var task_allocator = task_allocator_scn.instantiate()
		task_allocator.init_with_task(task_id, available_tasks[task_id])
		labor_allocators_container.add_child(task_allocator)

func _on_labor_overview_button_pressed():
	print("Hello button")
