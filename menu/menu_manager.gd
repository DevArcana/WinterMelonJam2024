extends Node

const MENU_SCENE_PATH = "res://menu/menu.tscn"
var menu_scene: PackedScene
var menu_instance: Menu

func _ready():
	menu_scene = load(MENU_SCENE_PATH)
	
func toggle():
	var tree = get_tree()
	if tree and tree.current_scene and tree.current_scene.scene_file_path != MENU_SCENE_PATH and not menu_instance:
		menu_instance = menu_scene.instantiate()
		menu_instance.is_scene_loaded = true
		get_tree().root.add_child(menu_instance)
	elif menu_instance:
		menu_instance.queue_free()
		menu_instance = null

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		toggle()
