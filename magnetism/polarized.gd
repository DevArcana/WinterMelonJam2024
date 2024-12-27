extends StaticBody2D
class_name Polarized

@export var polarity : Magnetism.Polarity = Magnetism.Polarity.INERT

func _ready():
	if polarity == Magnetism.Polarity.RED:
		self.modulate = Color.RED
	elif polarity == Magnetism.Polarity.BLUE:
		self.modulate = Color.BLUE
