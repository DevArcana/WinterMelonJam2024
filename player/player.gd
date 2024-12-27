extends CharacterBody2D

var dir : float = 0.0
var magnet_mode : MagnetMode = MagnetMode.INACTIVE
var magnet_target : Vector2 = Vector2.ZERO

enum MagnetMode {INACTIVE, RED, BLUE}

const EPSILON = 0.001
const JUMP_VELOCITY = 400.0
const GROUND_MAX_SPEED = 200.0
const GROUND_ACCEL = 1200.0
const GROUND_DECEL = 200.0
const GROUND_FRICTION = 3.0
const AIR_FRICTION = 0.5
const MAGNET_FORCE = 300.0

func _set_magnet_mode(mode: MagnetMode, target: Vector2 = Vector2.ZERO):
	magnet_mode = mode
	magnet_target = target
	
	if magnet_mode == MagnetMode.INACTIVE:
		%MagnetSprite.modulate = Color.WHITE
	elif magnet_mode == MagnetMode.RED:
		%MagnetSprite.modulate = Color.RED
	elif magnet_mode == MagnetMode.BLUE:
		%MagnetSprite.modulate = Color.BLUE

func _apply_magnet_force(delta):
	var magnet_dir = (magnet_target - global_position).normalized()
	if magnet_mode == MagnetMode.BLUE:
		magnet_dir = -magnet_dir
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

func _physics_air(delta):
	# Apply gravity
	if magnet_mode == MagnetMode.INACTIVE:
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
		if Input.is_action_just_pressed("jump"):
			velocity.y -= JUMP_VELOCITY
		
		_physics_ground(delta)
	else:
		_physics_air(delta)
		
	if magnet_mode == MagnetMode.INACTIVE:
		%Magnet.look_at(get_global_mouse_position())
		
		if %MagnetCast.is_colliding():
			if Input.is_action_just_pressed("fire_red"):
				_set_magnet_mode(MagnetMode.RED, %MagnetCast.get_collision_point())
			if Input.is_action_just_pressed("fire_blue"):
				_set_magnet_mode(MagnetMode.BLUE, %MagnetCast.get_collision_point())
	else:
		%Magnet.look_at(magnet_target)
		_apply_magnet_force(delta)
		if magnet_mode == MagnetMode.RED:
			if Input.is_action_just_released("fire_red"):
				_set_magnet_mode(MagnetMode.INACTIVE)
		elif magnet_mode == MagnetMode.BLUE:
			if Input.is_action_just_released("fire_blue"):
				_set_magnet_mode(MagnetMode.INACTIVE)
	
	move_and_slide()
