extends Item

@onready var particles: GPUParticles2D = $GPUParticles2D

var polarity: Magnetism.Polarity = Magnetism.Polarity.INERT

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
	pass
