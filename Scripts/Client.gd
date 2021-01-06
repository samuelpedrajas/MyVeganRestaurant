extends Node2D


signal served
signal leaving_angry

onready var patience_timer = $Sprite/Bubble/PatienceTimer
onready var bubble = $Sprite/Bubble
onready var deliveries = $Sprite/Bubble/Deliveries
var max_orders = 4
var separation = 30
var patience
var seconds_gained_on_delivery
var time_of_arrival

var rng

var idx
var bubble_initial_position = null
var __deliveries


func _ready():
	for _delivery in __deliveries:
		deliveries.add_child(_delivery)
	_resize()


func walk_in(destination):
	bubble.hide()
	$AnimationPlayer.walk_in(destination)


func walk_out():
	bubble.hide()
	self.patience_timer.stop()
	$AnimationPlayer.walk_out()


func die():
	print("Client died")
	queue_free()


func get_deliveries():
	if not bubble.is_visible():
		return []
	return deliveries.get_children()


func setup(_idx, _current_time, _deliveries, _max_arrival_time, _patience,
		_seconds_gained_on_delivery, _rng):
	self.idx = _idx
	self.time_of_arrival = _current_time
	self.seconds_gained_on_delivery = _seconds_gained_on_delivery
	self.patience = _patience
	self.rng = _rng
	self.__deliveries = _deliveries
	$ArrivalTime.set_text(str(_current_time))
	$AnimationPlayer.arrival_time = _max_arrival_time


func accepts_delivery(delivery):
	for _delivery in get_deliveries():
		if _delivery.reference == delivery.reference and _delivery.served == false:
			return true
	return false


func receive_delivery(delivery):
	for _delivery in get_deliveries():
		if _delivery.reference == delivery.reference and _delivery.served == false:
			delivery.set_client(self, _delivery)
			_delivery.served = true
			_increase_patience()
			break


func remove_delivery(_delivery):
	deliveries.remove_child(_delivery)
	_delivery.queue_free()
	if get_deliveries().size() < 1:
		emit_signal("served", self)
		walk_out()
	else:
		_resize()


func is_red():
	return self.patience_timer.red


func get_patience_percentage():
	return self.patience_timer.get_percentage()


func _increase_patience():
	self.patience_timer.add_patience(seconds_gained_on_delivery)


func _resize():
	var bubble_size = bubble.get_size()
	var x_center = bubble_size.x / 2.0

	var acc = 0
	for child in get_deliveries():
		var half = child.get_height() / 2.0
		acc += half + separation + child.get_y_offset() / 2.0
		child.set_position(Vector2(x_center, acc))
		acc += half - child.get_y_offset() / 2.0
	var remaining_space = deliveries.get_size().y - acc
	for child in get_deliveries():
		child.position.y += remaining_space / 2.0


func _on_AnimationPlayer_arrived():
	bubble.show()
	self.patience_timer.start(patience)


func _on_PatienceTimer_angry():
	bubble.hide()
	self.patience_timer.stop()
	$AnimationPlayer.walk_out_angry()
	emit_signal("leaving_angry", self)
