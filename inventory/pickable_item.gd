extends Node

@export_file("*.tscn") var item_scene: String

var player: Player

func _ready():
	$Label.visible = false

func _on_area_2d_body_entered(body: Node2D):
	if body.is_in_group("player"):
		$Label.visible = true
		player = body as Player

func _on_area_2d_body_exited(body: Node2D):
	if body.is_in_group("player"):
		$Label.visible = false
		player = null

func _physics_process(delta):
	if player and Input.is_action_just_pressed("use"):
		queue_free()
		player.pick_up(item_scene)
		
