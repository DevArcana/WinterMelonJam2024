extends Item

@onready var particles: GPUParticles2D = $GPUParticles2D

var polarity: Magnetism.Polarity = Magnetism.Polarity.INERT
var range: Array[Polarized] = []

const MAGNET_FORCE: float = 2400

func _ready():
	particles.amount_ratio = 0.0

func _set_polarity(new_polarity: Magnetism.Polarity):
	polarity = new_polarity
	
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
	DebugDraw2D.set_text("in range", len(range))
	if len(range) > 0 and polarity != Magnetism.Polarity.INERT:
		var v = Vector2.ZERO
		for polarized in range:
			var pos = polarized.global_position
			var d_pos = pos - player.global_position
			var d = d_pos.length()
			var dir = d_pos.normalized()
			var l = 1 - clamp(d/150, 0.0, 1.0)
			var f = MAGNET_FORCE * l * dir
			if polarity == polarized.polarity:
				f = -f
			v += f
		player.velocity += v * delta

func _on_area_2d_body_entered(body):
	var polarized = body as Polarized
	if polarized:
		range.append(polarized)

func _on_area_2d_body_exited(body):
	var polarized = body as Polarized
	if polarized:
		var i = range.find(polarized)
		if i >= 0:
			range.remove_at(i)
