extends CharacterBody2D

var dir : float = 0.0
var magnet_mode : Magnetism.Polarity = Magnetism.Polarity.INERT
var magnet_target : Vector2 = Vector2.ZERO
var magnet_push : bool = false
var step_timer = 0.0

const EPSILON = 0.001
const JUMP_VELOCITY = 400.0
const GROUND_MAX_SPEED = 200.0
const GROUND_ACCEL = 1200.0
const GROUND_DECEL = 200.0
const GROUND_FRICTION = 3.0
const AIR_FRICTION = 0.5
const MAGNET_FORCE = 300.0
const STEP_INTERVAL = 1.0

func _set_magnet_mode(mode: Magnetism.Polarity, target_polarity: Magnetism.Polarity = Magnetism.Polarity.INERT, target: Vector2 = Vector2.ZERO):
	magnet_mode = mode
	magnet_target = target
	magnet_push = mode == target_polarity
	
	if magnet_mode == Magnetism.Polarity.INERT:
		%MagnetSprite.modulate = Color.WHITE
		%MagnetSprite.play("default")
		%MagnetAudio.stop()
	elif magnet_mode == Magnetism.Polarity.RED:
		%MagnetSprite.modulate = Color.RED
		%MagnetSprite.play("pull")
		%MagnetAudio.play()
	elif magnet_mode == Magnetism.Polarity.BLUE:
		%MagnetSprite.modulate = Color.BLUE
		%MagnetSprite.play("push")
		%MagnetAudio.play()

func _apply_magnet_force(delta):
	var diff = magnet_target - global_position
	var dist = diff.length()
	var magnet_dir = diff.normalized()
	if magnet_push:
		magnet_dir = -magnet_dir
	
	%MagnetAudio.pitch_scale = clamp((dist / 400) + 0.7, 0.7, 1.0)
	velocity = magnet_dir * MAGNET_FORCE

func _physics_ground(delta):
	# Apply input
	var speed = abs(velocity.x)
	var remaining = GROUND_MAX_SPEED - speed
	if remaining > 0:
		var dx = delta * GROUND_ACCEL
		velocity.x += min(dx, remaining) * dir
	
	# Apply friction
	speed = abs(velocity.x)
	var drop = max(speed, GROUND_DECEL) * GROUND_FRICTION * delta
	var new_speed = max(speed - drop, 0.0)
	if speed > 0.0:
		new_speed /= speed
	velocity.x *= new_speed
	
	if is_zero_approx(velocity.x):
		step_timer = 0.0
	else:
		step_timer -= abs(velocity.x) * 0.03 * delta
		if step_timer <= 0.0:
			step_timer = STEP_INTERVAL
			%PlayerAudioStep.play()

func _physics_air(delta):
	# Apply gravity
	if magnet_mode == Magnetism.Polarity.INERT:
		velocity += get_gravity() * delta
	
	# Apply friction
	var speed = velocity.length()
	var drop = speed * AIR_FRICTION * delta
	var new_speed = max(speed - drop, 0.0)
	if speed > 0.0:
		new_speed /= speed
	velocity *= new_speed

func _physics_process(delta):
	dir = Input.get_axis("left", "right")
	
	if is_on_floor():
		if velocity.y >= 0.0 and Input.is_action_just_pressed("jump"):
			velocity.y -= JUMP_VELOCITY
			%PlayerAudioHop.play()
		
		_physics_ground(delta)
	else:
		_physics_air(delta)
		
	if magnet_mode == Magnetism.Polarity.INERT:
		%Magnet.look_at(get_global_mouse_position())
		
		if %MagnetCast.is_colliding():
			var hit = %MagnetCast.get_collider()
			if hit is Polarized and hit.polarity != Magnetism.Polarity.INERT:
				if Input.is_action_just_pressed("fire_red"):
					_set_magnet_mode(Magnetism.Polarity.RED, hit.polarity, %MagnetCast.get_collision_point())
				if Input.is_action_just_pressed("fire_blue"):
					_set_magnet_mode(Magnetism.Polarity.BLUE, hit.polarity, %MagnetCast.get_collision_point())
	else:
		%Magnet.look_at(magnet_target)
		_apply_magnet_force(delta)
		if magnet_mode == Magnetism.Polarity.RED:
			if Input.is_action_just_released("fire_red"):
				_set_magnet_mode(Magnetism.Polarity.INERT)
		elif magnet_mode == Magnetism.Polarity.BLUE:
			if Input.is_action_just_released("fire_blue"):
				_set_magnet_mode(Magnetism.Polarity.INERT)
	
	move_and_slide()
