extends CanvasLayer
class_name Menu

var is_scene_loaded = false

func _ready():
	%Start.text = "START" if not is_scene_loaded else "RESTART"
	
	if not is_scene_loaded:
		%Skip.visible = false

func _on_start_pressed():
	if is_scene_loaded:
		get_tree().reload_current_scene()
		MenuManager.toggle()
	else:
		get_tree().change_scene_to_file("res://scenes/level_01.tscn")

func _on_exit_pressed():
	get_tree().quit()


func _on_skip_pressed():
	var current_level = get_tree().current_scene.scene_file_path
	
	if current_level == "res://scenes/level_01.tscn":
		get_tree().change_scene_to_file("res://scenes/level_02.tscn")
	elif current_level == "res://scenes/level_02.tscn":
		get_tree().change_scene_to_file("res://scenes/level_03.tscn")
	elif current_level == "res://scenes/level_025.tscn":
		get_tree().change_scene_to_file("res://scenes/level_02.tscn")
	elif current_level == "res://scenes/level_03.tscn":
		get_tree().change_scene_to_file("res://scenes/level_04.tscn")
	elif current_level == "res://scenes/level_04.tscn":
		get_tree().change_scene_to_file("res://scenes/level_05.tscn")
	elif current_level == "res://scenes/level_05.tscn":
		get_tree().change_scene_to_file("res://scenes/level_final.tscn")
	elif current_level == "res://scenes/level_final.tscn":
		get_tree().change_scene_to_file("res://scenes/level_01.tscn")
