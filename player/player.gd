extends CharacterBody2D

var dir : float = 0.0

const EPSILON = 0.001
const JUMP_VELOCITY = 400.0
const GROUND_MAX_SPEED = 200.0
const GROUND_ACCEL = 1200.0
const GROUND_DECEL = 200.0
const GROUND_FRICTION = 3.0
const AIR_FRICTION = 0.5

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
			
	move_and_slide()
