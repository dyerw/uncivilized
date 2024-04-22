extends VBoxContainer

var task_id: String

var current_labor: int = 0:
	set(value):
		current_labor = value
		_update_label()

var max_labor: int = 0:
	set(value):
		max_labor = value
		_update_label()

signal task_allocation_increased(task_id: String)
signal task_allocation_decreased(task_id: String)

func init_with_task(tid: String, max_labor: int):
	task_id = tid
	$TaskNameLabel.text = GameConfig.get_task_display_name(task_id)

func _update_label():
	$HBoxContainer/LaborAllocatedLabel.text = "%s / %s" % [current_labor, max_labor]

func _on_subtract_labor_button_pressed():
	task_allocation_decreased.emit(task_id)

func _on_add_labor_button_pressed():
	task_allocation_increased.emit(task_id)
