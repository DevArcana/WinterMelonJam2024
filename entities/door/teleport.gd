extends Node

@export_file("*.tscn") var scene : String

func _ready():
	$Label.visible = false

func _physics_process(delta):
	if $Label.visible:
		get_tree().change_scene_to_file(scene)

func _on_area_2d_body_entered(body):
	if not scene or len(scene) == 0:
		return
		
	if body.is_in_group("player"):
		$Label.visible = true

func _on_area_2d_body_exited(body):
	if not scene or len(scene) == 0:
		return
		
	if body.is_in_group("player"):
		$Label.visible = false
