extends AnimatedSprite2D

var triggered = false
var last_char_index = -1

const MESSAGE_1 = "Hey! You're late."
const MESSAGE_2 = "Sorry but this just won't do..."
const MESSAGE_3 = "You're fired!"

func _ready():
	$Control/Label.text = ""

func clear_msg():
	$Control/Label.text = ""
	last_char_index = -1
	
func display_msg(char_index: int, msg: String):
	if char_index > last_char_index:
		last_char_index = char_index
		$Control/Label.text += msg[char_index]
		$SfxType.play()

func flip():
	flip_h = !flip_h
	
func add_closing_thought():
	Thoughts.enqueue_msg("...")
	Thoughts.enqueue_msg("That wasn't exactly what I was expecting.")
	Thoughts.enqueue_msg("Let's hope the Easter Bunny is hiring...")
	Thoughts.enqueue_msg("[THE END]")
	
func idle():
	self.play("default")

func walk():
	self.play("walk")

func _on_area_2d_body_entered(body: Node2D):
	if triggered:
		return
	if body.is_in_group("player"):
		var player = body as Player
		if player:
			triggered = true
			var camera = PhantomCameraManager.get_phantom_camera_2ds()[0] as PhantomCamera2D
			var tween = get_tree().create_tween()
			tween.tween_callback(player.enter_cutscene)
			tween.tween_property(camera, "zoom", Vector2.ONE * 6, 0.5)
			tween.tween_callback(walk)
			tween.tween_property(self, "position:x", -470, 3.0).as_relative()
			tween.tween_callback(idle)
			tween.tween_callback(clear_msg).set_delay(0.5)
			tween.tween_method(display_msg.bind(MESSAGE_1), 0, len(MESSAGE_1) - 1, 1)
			tween.tween_callback(clear_msg).set_delay(1.0)
			tween.tween_method(display_msg.bind(MESSAGE_2), 0, len(MESSAGE_2) - 1, 1)
			tween.tween_callback(clear_msg).set_delay(1.0)
			tween.tween_method(display_msg.bind(MESSAGE_3), 0, len(MESSAGE_3) - 1, 0.5)
			tween.tween_callback(clear_msg).set_delay(1.0)
			tween.tween_callback(flip)
			tween.tween_callback(walk)
			tween.tween_property(self, "position:x", 30, 0.5).as_relative().set_trans(Tween.TRANS_CUBIC)
			tween.tween_callback(idle)
			tween.tween_callback(flip)
			tween.tween_property(self, "position:y", -1000, 1.0).as_relative().set_trans(Tween.TRANS_EXPO).set_delay(1.0)
			tween.tween_property(camera, "zoom", Vector2.ONE * 4, 0.5)
			tween.tween_callback(player.exit_cutscene)
			tween.tween_callback(add_closing_thought)
			tween.tween_callback(queue_free)
			await tween.finished
