extends Control

var task_id: String

func init_with_task(tid: String, max_labor: int):
	task_id = tid
	$VBoxContainer/TaskNameLabel.text = GameConfig.get_task_display_name(task_id)
