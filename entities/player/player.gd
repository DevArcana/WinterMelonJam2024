extends CharacterBody2D

@onready var ref_magnet_raycast = $Magnet/Raycast
@onready var ref_magnet_sprite = $Magnet/Sprite
@onready var ref_magnet = $Magnet
@onready var ref_player_sprite = $Sprite

var dir : float = 0.0
var magnet_mode : Magnetism.Polarity = Magnetism.Polarity.INERT
var magnet_target : Vector2 = Vector2.ZERO
var magnet_push : bool = false
var step_timer = 0.0
var was_on_floor = false

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
		ref_magnet_sprite.modulate = Color.WHITE
		ref_magnet_sprite.play("default")
		$SfxMagnet.stop()
	elif magnet_mode == Magnetism.Polarity.RED:
		ref_magnet_sprite.modulate = Color.RED
		ref_magnet_sprite.play("pull")
		$SfxMagnet.play()
	elif magnet_mode == Magnetism.Polarity.BLUE:
		ref_magnet_sprite.modulate = Color.BLUE
		ref_magnet_sprite.play("push")
		$SfxMagnet.play()

func _apply_magnet_force(delta):
	var diff = magnet_target - global_position
	var dist = diff.length()
	var magnet_dir = diff.normalized()
	if magnet_push:
		magnet_dir = -magnet_dir
	
	$SfxMagnet.pitch_scale = clamp((dist / 400) + 0.7, 0.7, 1.0)
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
			$SfxWalk.play()

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
		if not was_on_floor:
			was_on_floor = true
			$SfxLand.play()
		
		if velocity.y >= 0.0 and Input.is_action_just_pressed("jump"):
			velocity.y -= JUMP_VELOCITY
			$SfxJump.play()
		
		_physics_ground(delta)
	else:
		_physics_air(delta)
		was_on_floor = false
		
	if magnet_mode == Magnetism.Polarity.INERT:
		ref_magnet.look_at(get_global_mouse_position())
		
		if ref_magnet_raycast.is_colliding():
			var hit = ref_magnet_raycast.get_collider()
			if hit is Polarized and hit.polarity != Magnetism.Polarity.INERT:
				if Input.is_action_just_pressed("fire_red"):
					_set_magnet_mode(Magnetism.Polarity.RED, hit.polarity, ref_magnet_raycast.get_collision_point())
				if Input.is_action_just_pressed("fire_blue"):
					_set_magnet_mode(Magnetism.Polarity.BLUE, hit.polarity, ref_magnet_raycast.get_collision_point())
	else:
		ref_magnet.look_at(magnet_target)
		_apply_magnet_force(delta)
		if magnet_mode == Magnetism.Polarity.RED:
			if Input.is_action_just_released("fire_red"):
				_set_magnet_mode(Magnetism.Polarity.INERT)
		elif magnet_mode == Magnetism.Polarity.BLUE:
			if Input.is_action_just_released("fire_blue"):
				_set_magnet_mode(Magnetism.Polarity.INERT)
	
	if velocity.x > EPSILON:
		ref_player_sprite.play("walk")
		ref_player_sprite.flip_h = false
	elif velocity.x < -EPSILON:
		ref_player_sprite.play("walk")
		ref_player_sprite.flip_h = true
	else:
		ref_player_sprite.play("default")
		ref_player_sprite.flip_h = false
	
	move_and_slide()
	
	if not is_on_floor():
		var speed = velocity.length() - 200
		var f = clamp(speed / 1200, 0.0, 1.0)
		$SfxWind.volume_db = -40 + f * 40
	else:
		$SfxWind.volume_db = lerp($SfxWind.volume_db, -40.0, delta)
