extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -250.0
const MAGNET_FORCE = 5000.0

enum MagnetMode {INACTIVE, RED, BLUE}
var magnet_mode : MagnetMode = MagnetMode.INACTIVE

func switch_magnet_mode(mode: MagnetMode):
	if mode == magnet_mode:
		return
		
	magnet_mode = mode
		
	if magnet_mode == MagnetMode.INACTIVE:
		%MagnetSprite.modulate = Color.WHITE
	elif magnet_mode == MagnetMode.RED:
		%MagnetSprite.modulate = Color.RED
	elif magnet_mode == MagnetMode.BLUE:
		%MagnetSprite.modulate = Color.BLUE

func _process(delta):
	%Magnet.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("fire_blue"):
		switch_magnet_mode(MagnetMode.BLUE)
	elif Input.is_action_just_pressed("fire_red"):
		switch_magnet_mode(MagnetMode.RED)
	elif Input.is_action_just_released("fire_blue") and magnet_mode == MagnetMode.BLUE:
		switch_magnet_mode(MagnetMode.INACTIVE)
	elif Input.is_action_just_released("fire_red") and magnet_mode == MagnetMode.RED:
		switch_magnet_mode(MagnetMode.INACTIVE)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if %MagnetCast.is_colliding():
		var point = %MagnetCast.get_collision_point()
		var diff = (point - global_position).normalized()
		
		if magnet_mode == MagnetMode.RED:
			velocity += diff * delta * MAGNET_FORCE
		elif magnet_mode == MagnetMode.BLUE:
			velocity -= diff * delta * MAGNET_FORCE

	move_and_slide()
