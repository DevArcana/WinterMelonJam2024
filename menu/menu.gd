extends CanvasLayer
class_name Menu

var is_scene_loaded = false

func _ready():
	%Start.text = "START" if not is_scene_loaded else "RESTART"

func _on_start_pressed():
	if is_scene_loaded:
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file("res://scenes/level_01.tscn")

func _on_exit_pressed():
	get_tree().quit()
