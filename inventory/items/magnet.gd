extends Item

var polarity: Magnetism.Polarity = Magnetism.Polarity.INERT
var target: Polarized
var target_hit: Vector2

func _set_polarity(new_polarity: Magnetism.Polarity):
	polarity = new_polarity
	target = null
	
	if polarity == Magnetism.Polarity.INERT:
		$Sprite.modulate = Color.WHITE
		$Sprite.play("default")
		$SfxMagnet.stop()
	elif polarity == Magnetism.Polarity.RED:
		$Sprite.modulate = Color.RED
		$Sprite.play("push")
		$SfxMagnet.play()
	elif polarity == Magnetism.Polarity.BLUE:
		$Sprite.modulate = Color.BLUE
		$Sprite.play("push")
		$SfxMagnet.play()

func left_mouse_button_pressed(player: Player) -> void:
	if polarity == Magnetism.Polarity.INERT:
		_set_polarity(Magnetism.Polarity.RED)

func right_mouse_button_pressed(player: Player) -> void:
	if polarity == Magnetism.Polarity.INERT:
		_set_polarity(Magnetism.Polarity.BLUE)

func left_mouse_button_released(player: Player) -> void:
	if polarity == Magnetism.Polarity.RED:
		_set_polarity(Magnetism.Polarity.INERT)

func right_mouse_button_released(player: Player) -> void:
	if polarity == Magnetism.Polarity.BLUE:
		_set_polarity(Magnetism.Polarity.INERT)

func physics_tick(player: Player, delta: float) -> void:
	if polarity != Magnetism.Polarity.INERT:
		$Raycast.force_raycast_update()
		if $Raycast.is_colliding():
			var collider = $Raycast.get_collider() as Polarized
			if collider and collider.polarity != Magnetism.Polarity.INERT:
				target = collider
				target_hit = $Raycast.get_collision_point()
		if target:
			if target.polarity == Magnetism.Polarity.INERT:
				target = null
				return
			
			player.target_with_item(target_hit)
			var push = target.polarity == polarity
			var diff = target_hit - player.global_position
			var dir = diff.normalized()
			var dist = diff.length_squared()
			var loss = 1 - clamp(dist/50000, 0.0, 1.0)
			var force = 2000 * loss
			var dv = dir * delta * force
			if push:
				dv = -dv
				$Sprite.play("push")
			else:
				$Sprite.play("pull")
			
			player.velocity += dv
