extends Node
class_name Item

@export var pickable_item: PackedScene

func left_mouse_button_pressed(player: Player) -> void:
	pass

func right_mouse_button_pressed(player: Player) -> void:
	pass

func left_mouse_button_released(player: Player) -> void:
	pass

func right_mouse_button_released(player: Player) -> void:
	pass

func physics_tick(player: Player, delta: float) -> void:
	pass

func drop(player: Player):
	queue_free()
	var item = pickable_item.instantiate() as Node2D
	item.global_position = player.global_position + Vector2.UP * 8
	player.get_parent().add_child(item)
