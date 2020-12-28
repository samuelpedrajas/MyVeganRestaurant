extends Node2D


export var patience_time = 15

var resolution = 0.1
var _count = 0

signal angry


func start(patience):
	patience_time = patience
	$Timer.set_paused(false)
	$Timer.set_wait_time(self.resolution)
	$Progress.show()
	_count = patience_time
	$Timer.start()


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

	if _testing_ai():
		print("AI killed a Client!!!")
	elif _count < resolution:
		print("Client is angry!")
		emit_signal("angry")
		stop()
	else:
		$Timer.start()


# TESTING


func _testing_ai():
	var enabled = true
	var threshold = 0.5
	if not enabled:
		return false
	var client = get_parent()
	var average_time_for_client = client.get_parent().average_time_for_client
	var current_time = patience_time - _count
	if current_time - threshold > average_time_for_client:
		return false
	if current_time + threshold > average_time_for_client:
		for dish in client.dishes:
			client.get_parent().get_parent().get_parent().add_score(dish.profit)
			client.remove_dish(dish)
		return true
	return false
