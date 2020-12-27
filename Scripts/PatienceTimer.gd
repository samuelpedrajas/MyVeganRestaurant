extends Node2D


export var patience_time = 15

var resolution = 0.1
var _count = 0

signal angry


func countdown():
	_count = patience_time
	$Timer.start()


func start():
	$Timer.set_paused(false)
	$Timer.set_wait_time(self.resolution)
	$Progress.show()
	countdown()


func add_patience(seconds):
	_count = min(patience_time, _count + seconds)


func stop():
	$Timer.stop()
	$Progress.hide()
	$Progress.set_value(0)


func _on_Timer_timeout():
	_count -= resolution
	var ellapsed_fraction = _count / patience_time

	$Progress.set_value(ellapsed_fraction * 100)

	if _count < resolution:
		print("Client is angry!")
		emit_signal("angry")
		stop()
	else:
		$Timer.start()
