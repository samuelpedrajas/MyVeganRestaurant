extends Node2D


signal served
signal leaving_angry

onready var patience_timer = $Sprite/Bubble/PatienceTimer
onready var bubble = $Sprite/Bubble
onready var dishes = $Sprite/Bubble/Dishes
var max_orders = 4
var separation = 30
var patience
var seconds_gained_on_delivery
var time_of_arrival

var rng

var idx
var bubble_initial_position = null
var __dishes


func _ready():
	for _dish in __dishes:
		dishes.add_child(_dish)
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


func get_dishes():
	if not bubble.is_visible():
		return []
	return dishes.get_children()


func setup(_idx, _current_time, _dishes, _max_arrival_time, _patience,
		_seconds_gained_on_delivery, _rng):
	self.idx = _idx
	self.time_of_arrival = _current_time
	self.seconds_gained_on_delivery = _seconds_gained_on_delivery
	self.patience = _patience
	self.rng = _rng
	self.__dishes = _dishes
	$ArrivalTime.set_text(str(_current_time))
	$AnimationPlayer.arrival_time = _max_arrival_time


func accepts_dish(dish):
	for _dish in get_dishes():
		if _dish.reference == dish.reference and _dish.served == false:
			return true
	return false


func receive_dish(dish):
	for _dish in get_dishes():
		if _dish.reference == dish.reference and _dish.served == false:
			dish.set_client(self, _dish)
			_dish.served = true
			_increase_patience()
			break


func remove_dish(_dish):
	dishes.remove_child(_dish)
	_dish.queue_free()
	if get_dishes().size() < 1:
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
	for child in get_dishes():
		var half = child.get_height() / 2.0
		acc += half + separation + child.get_y_offset() / 2.0
		child.set_position(Vector2(x_center, acc))
		acc += half - child.get_y_offset() / 2.0
	var remaining_space = dishes.get_size().y - acc
	for child in get_dishes():
		child.position.y += remaining_space / 2.0


func _on_AnimationPlayer_arrived():
	bubble.show()
	self.patience_timer.start(patience)


func _on_PatienceTimer_angry():
	bubble.hide()
	self.patience_timer.stop()
	$AnimationPlayer.walk_out_angry()
	emit_signal("leaving_angry", self)
