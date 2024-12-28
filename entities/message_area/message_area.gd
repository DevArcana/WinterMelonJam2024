extends Node2D

@export var messages : Array[String] = []
@export var char_speed : float = 0.1
@export var message_delay : float = 1.0
@export var clear_last_message : bool = false
@export var follow : bool = false

@onready var label = $Control/Label

var triggered = false
var current_message_index = -1
var current_char_index = 0
var waiting = false
var finished = false
var timer = 0
var follow_target : Node2D

func _ready():
	label.text = ""
	waiting = true
	timer = message_delay

func _on_body_entered(body):
	triggered = true
	follow_target = body

func _physics_process(delta):
	if triggered and not finished:
		
		if follow and follow_target:
			global_position = follow_target.global_position + Vector2.UP * 8
		
		timer += delta
		
		# Handle message delay
		if waiting:
			if timer >= message_delay:
				timer = 0.0
				waiting = false
				
				# Switch to next message
				current_message_index += 1
				current_char_index = 0
				if current_message_index >= len(messages):
					finished = true
					if clear_last_message:
						label.text = ""
						queue_free()
				else:
					label.text = ""
			return
		
		if timer < char_speed:
			return
		timer = 0.0
		
		var message = messages[current_message_index]
		
		# Check if already printed whole msg
		if current_char_index >= len(message):
			waiting = true
			return
		
		var char = message[current_char_index]
		if char == "\\" and message[current_char_index + 1] == "n":
			current_char_index += 2
			label.text += "\n"
		else:
			current_char_index += 1
			label.text += char
		
