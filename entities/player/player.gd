extends CharacterBody2D
class_name Player

@onready var ref_player_sprite = $Sprite
@onready var ref_held_item = $HeldItem

var dir : float = 0.0
var step_timer = 0.0
var was_on_floor = false
var hand_rot_override = false

const EPSILON = 0.001
const JUMP_VELOCITY = 400.0
const GROUND_MAX_SPEED = 200.0
const GROUND_ACCEL = 1200.0
const GROUND_DECEL = 200.0
const GROUND_FRICTION = 3.0
const AIR_MAX_SPEED = 100.0
const AIR_ACCEL = 1200.0
const AIR_DECEL = 300.0
const AIR_FRICTION = 0.3
const STEP_INTERVAL = 1.0

func pick_up(item_scene: String) -> bool:
	if ref_held_item.get_child_count() > 0:
		return false
	
	ref_held_item.add_child(load(item_scene).instantiate())
	return true

func target_with_item(pos: Vector2):
	hand_rot_override = true
	ref_held_item.look_at(pos)

func _physics_ground(delta):
	# Apply input
	var speed = velocity.dot(Vector2(dir, 0))
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
	velocity += get_gravity() * delta
	
	# Apply input
	var speed = velocity.dot(Vector2(dir, 0))
	var remaining = AIR_MAX_SPEED - speed
	if remaining > 0:
		var dx = delta * AIR_ACCEL
		velocity.x += min(dx, remaining) * dir
	
	# Apply friction
	speed = velocity.length()
	var drop = max(speed, AIR_DECEL) * AIR_FRICTION * delta
	var new_speed = max(speed - drop, 0.0)
	if speed > 0.0:
		new_speed /= speed
	velocity *= new_speed

func _physics_process(delta):
	dir = Input.get_axis("left", "right")
	
	hand_rot_override = false
	if ref_held_item.get_child_count() > 0:
		var held_item = ref_held_item.get_child(0) as Item
		if held_item:
			if Input.is_action_just_pressed("drop_item"):
				held_item.drop(self)
				$SfxDropItem.play()
			if Input.is_action_just_pressed("fire_primary"):
				held_item.left_mouse_button_pressed(self)
			if Input.is_action_just_pressed("fire_secondary"):
				held_item.right_mouse_button_pressed(self)
			if Input.is_action_just_released("fire_primary"):
				held_item.left_mouse_button_released(self)
			if Input.is_action_just_released("fire_secondary"):
				held_item.right_mouse_button_released(self)
			held_item.physics_tick(self, delta)
	if not hand_rot_override:
		ref_held_item.look_at(get_global_mouse_position())
	
	if is_on_floor():
		if not was_on_floor:
			was_on_floor = true
			$SfxLand.play()
		
		if velocity.y >= 0.0 and Input.is_action_pressed("jump"):
			velocity.y -= JUMP_VELOCITY
			$SfxJump.play()
		
		_physics_ground(delta)
	else:
		_physics_air(delta)
		was_on_floor = false
	
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
	
	if global_position.y > 3000:
		Thoughts.interrupt()
		get_tree().reload_current_scene()
