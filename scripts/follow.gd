extends Node2D

@export var target: Node2D

func _ready():
	top_level = true
	if not target:
		target = get_parent()

func _physics_process(delta):
	global_position = target.global_position
	global_rotation = target.global_rotation
