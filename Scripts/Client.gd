extends Node2D


signal served
signal leaving_angry

onready var bubble = $Sprite/Bubble
var max_orders = 4
var separation = 30
var patience
var seconds_gained_on_delivery
var time_of_arrival

var rng

var idx
var bubble_initial_position = null
var dishes


func _ready():
	for _dish in dishes:
		bubble.add_child(_dish)
	_resize()


func walk_in(destination):
	bubble.hide()
	$AnimationPlayer.walk_in(destination)


func walk_out():
	bubble.hide()
	$PatienceTimer.stop()
	$AnimationPlayer.walk_out()


func die():
	print("Client died")
	queue_free()


func get_dishes():
	if not bubble.is_visible():
		return []
	return bubble.get_children()


func setup(_idx, _current_time, _dishes, _max_arrival_time, _patience,
		_seconds_gained_on_delivery, _rng):
	self.idx = _idx
	self.time_of_arrival = _current_time
	self.seconds_gained_on_delivery = _seconds_gained_on_delivery
	self.patience = _patience
	self.rng = _rng
	self.dishes = _dishes
	$ArrivalTime.set_text(str(_current_time))
	$AnimationPlayer.arrival_time = _max_arrival_time


func accepts_dish(dish):
	if not bubble.is_visible():
		return false
	for _dish in bubble.get_children():
		if _dish.reference == dish.reference and _dish.served == false:
			return true
	return false


func receive_dish(dish):
	for _dish in bubble.get_children():
		if _dish.reference == dish.reference and _dish.served == false:
			dish.set_client(self, _dish)
			_dish.served = true
			_increase_patience()
			break


func remove_dish(_dish):
	bubble.remove_child(_dish)
	_dish.queue_free()
	if bubble.get_child_count() < 1:
		emit_signal("served", self)
		walk_out()
	else:
		_resize()


func is_red():
	return $PatienceTimer.red


func get_patience_percentage():
	return $PatienceTimer.get_percentage()


func _increase_patience():
	$PatienceTimer.add_patience(seconds_gained_on_delivery)


func _resize():
	if bubble_initial_position == null:
		bubble_initial_position = bubble.get_position()
	var bubble_size = bubble.get_size()
	var x_center = bubble_size.x / 2.0
	var new_bubble_h = separation

	for child in bubble.get_children():
		new_bubble_h += child.get_height() + separation

	bubble.set_size(Vector2(bubble_size.x, new_bubble_h))
	bubble.set_position(bubble_initial_position - Vector2(
		0, new_bubble_h * bubble.get_scale().y
	))

	var acc = 0
	for i in range(bubble.get_child_count()):
		var child = bubble.get_child(i)
		var half = child.get_height() / 2.0
		acc += half + separation + child.get_y_offset() / 2.0
		child.set_position(Vector2(x_center, acc))
		acc += half - child.get_y_offset() / 2.0


func _on_AnimationPlayer_arrived():
	bubble.show()
	$PatienceTimer.start(patience)


func _on_PatienceTimer_angry():
	bubble.hide()
	$PatienceTimer.stop()
	$AnimationPlayer.walk_out_angry()
	emit_signal("leaving_angry", self)
