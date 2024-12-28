extends Item

@onready var particles: GPUParticles2D = $GPUParticles2D

var polarity: Magnetism.Polarity = Magnetism.Polarity.INERT
var target: Polarized
var target_hit: Vector2

const PARTICLE_SPEED = 256

func _ready():
	particles.amount_ratio = 0.0

func _set_polarity(new_polarity: Magnetism.Polarity):
	polarity = new_polarity
	target = null
	
	var dist = 500
	var material = particles.process_material as ParticleProcessMaterial
	material.emission_box_extents.x = dist/2
	material.emission_shape_offset.x = dist/2 + 10
	material.radial_accel_max = PARTICLE_SPEED/2
	material.radial_accel_min = -PARTICLE_SPEED
	
	if polarity == Magnetism.Polarity.INERT:
		$Sprite.modulate = Color.WHITE
		$Sprite.play("default")
		$SfxMagnet.stop()
		particles.modulate = Color.WHITE
		particles.amount_ratio = 0.0
	elif polarity == Magnetism.Polarity.RED:
		$Sprite.modulate = Color.RED
		$Sprite.play("push")
		$SfxMagnet.play()
		particles.modulate = Color.RED
		particles.amount_ratio = 1.0
	elif polarity == Magnetism.Polarity.BLUE:
		$Sprite.modulate = Color.BLUE
		$Sprite.play("push")
		$SfxMagnet.play()
		particles.modulate = Color.BLUE
		particles.amount_ratio = 1.0

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
	var material = particles.process_material as ParticleProcessMaterial	
	var polarized: Polarized
	var hit_point: Vector2
	var hit = false
	
	$Raycast.force_raycast_update()
	if $Raycast.is_colliding():
		hit = true
		var collider = $Raycast.get_collider()
		polarized = collider as Polarized
		hit_point = $Raycast.get_collision_point()
		
	if target:
		var diff = target_hit - player.global_position
		var dist = diff.length()
		material.emission_box_extents.x = dist/2
		material.emission_shape_offset.x = dist/2 + 10
	elif hit:
		var diff = hit_point - player.global_position
		var dist = diff.length()
		material.emission_box_extents.x = dist/2
		material.emission_shape_offset.x = dist/2 + 10
	else:
		var dist = 500
		material.emission_box_extents.x = dist/2
		material.emission_shape_offset.x = dist/2 + 10
		
	if polarity != Magnetism.Polarity.INERT:
		if not target and polarized and polarized.polarity != Magnetism.Polarity.INERT:
			target = polarized
			target_hit = hit_point
		if target:
			if target.polarity == Magnetism.Polarity.INERT:
				target = null
				return
			
			player.target_with_item(target_hit)
			var push = target.polarity == polarity
			var diff = target_hit - player.global_position
			var dir = diff.normalized()
			var dist_squared = diff.length_squared()
			var dist = sqrt(dist_squared)
			var loss = 1 - clamp(dist_squared/50000, 0.0, 1.0)
			var force = 2000 * loss
			var dv = dir * delta * force
			
			if push:
				dv = -dv
				$Sprite.play("push")
				material.radial_accel_max = PARTICLE_SPEED
				material.radial_accel_min = PARTICLE_SPEED
			else:
				$Sprite.play("pull")
				material.radial_accel_max = -PARTICLE_SPEED
				material.radial_accel_min = -PARTICLE_SPEED
			
			player.velocity += dv
