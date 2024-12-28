extends Area2D

@export_file("*.tscn") var scene : String

var inside = false

func _on_body_entered(body):
	inside = true

func _on_body_exited(body):
	inside = false

func _physics_process(delta):
	if inside and Input.is_action_just_pressed("use"):
		get_tree().change_scene_to_file(scene)
