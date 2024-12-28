extends Area2D

@export_file("*.tscn") var scene : String

var inside = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		inside = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		inside = false

func _physics_process(delta):
	if inside and Input.is_action_just_pressed("use"):
		get_tree().change_scene_to_file(scene)
