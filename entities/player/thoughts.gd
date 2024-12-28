extends Node

# This class is autoloaded into a global Thoughts variable

var queue: Array[String] = []
var interrupted = false

func interrupt():
	queue.clear()
	interrupted = true

func get_interrupt():
	if interrupted:
		interrupted = false
		return true
	return false

func enqueue_msg(msg: String):
	queue.append(msg)

func dequeue_msg() -> String:
	if len(queue) > 0:
		return queue.pop_front()
	
	return ""

func has_enqueued() -> bool:
	return len(queue) > 0
