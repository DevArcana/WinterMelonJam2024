extends Node

@onready var label = $Label

var timer: float = 0.0
var waiting: bool = false
var current_msg: String = ""
var char_index: int = 0

const CHAR_TIME: float = 0.03
const MSG_TIME: float = 1.0

func _ready():
	label.text = ""

func _physics_process(delta):
	# if there is nothing to do, exit early
	if not waiting and not Thoughts.has_enqueued() and current_msg == "":
		timer = 0.0
		return
	
	timer += delta
	
	if waiting:
		if timer >= MSG_TIME:
			waiting = false
			timer = 0.0
			label.text = ""
		return
	
	# no message to display, grab from queue
	if current_msg == "":
		if Thoughts.has_enqueued():
			var msg = Thoughts.dequeue_msg()
			if msg != "":
				current_msg = msg
				char_index = 0
	
	if current_msg != "" and timer >= CHAR_TIME:
		timer = 0.0
		
		if char_index >= len(current_msg):
			current_msg = ""
			waiting = true
			return
			
		var char = current_msg[char_index]
		if char == "\\" and current_msg[char_index + 1] == "n":
			char_index += 2
			label.text += "\n"
		else:
			char_index += 1
			label.text += char
