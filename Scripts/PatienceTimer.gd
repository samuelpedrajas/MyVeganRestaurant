extends Node2D


export var patience_time = 15
var red_area_portion = 0.4
var red = false

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


func get_percentage():
	return $Progress.get_value()


func stop():
	$Timer.stop()
	$Progress.hide()
	$Progress.set_value(0)


func _on_Timer_timeout():
	_count -= resolution
	var ellapsed_fraction = _count / patience_time

	var new_style = StyleBoxFlat.new()
	$Progress.set_value(ellapsed_fraction * 100)
	if $Progress.get_value() <= red_area_portion * 100.0:
		new_style.set_bg_color(Color("#ff0000"))
		red = true
	else:
		new_style.set_bg_color(Color("#00a000"))
		red = false
	$Progress.set('custom_styles/fg', new_style) #

	if _testing_ai():
		print("AI killed a Client!!!")
	elif _count < resolution:
		print("Client is angry!")
		emit_signal("angry")
		stop()
	else:
		$Timer.start()


# TESTING


var average_time_for_client = null
func _testing_ai():
	var enabled = false
	var threshold = 0.5
	if not enabled:
		return false
	var client = get_parent().get_parent().get_parent()
	var client_area = client.get_parent()
	if average_time_for_client == null:
		average_time_for_client = client_area.average_time_for_client
		if client_area.current_n_clients > 1:
			average_time_for_client *= 2
	var current_time = patience_time - _count
	if current_time - threshold > average_time_for_client:
		return false
	if current_time + threshold > average_time_for_client:
		for dish in client.get_dishes():
			client_area.get_parent().get_parent().add_score(dish.profit)
			client.remove_dish(dish)
		return true
	return false
