extends Node2D


onready var bubble = $Sprite/Bubble
var max_orders = 4
var separation = 30

var menu
var rng

var bubble_initial_position = null


func walk_in(destination):
	bubble.hide()
	$AnimationPlayer.walk_in(destination)


func walk_out():
	bubble.hide()
	$AnimationPlayer.walk_out()


func die():
	print("Client died")
	queue_free()


func setup(_menu, _rng):
	self.menu = _menu
	self.rng = _rng


func accepts_dish(dish):
	for _dish in bubble.get_children():
		if _dish.reference == dish.reference and _dish.served == false:
			return true
	return false


func receive_dish(dish):
	for _dish in bubble.get_children():
		if _dish.reference == dish.reference and _dish.served == false:
			dish.set_client(self, _dish)
			_dish.served = true
			break


func remove_dish(_dish):
	bubble.remove_child(_dish)
	_dish.queue_free()
	if bubble.get_child_count() < 1:
		walk_out()
	else:
		_resize()


func select_dishes():
	var categories = menu.get_children()
	var n_categories = menu.get_child_count()
	var n_orders = rng.randi_range(1, max_orders)
	var orders = []
	for _unused in range(n_orders):
		var i = rng.randi_range(0, n_categories - 1)
		var category = categories[i]
		# get deliverable dishes
		var dishes = []
		for dish in category.get_children():
			if dish.deliverable:
				dishes.append(dish)
		var n_dishes = dishes.size()
		var j = rng.randi_range(0, n_dishes - 1)
		var dish_obj = {
			"dish": dishes[j].duplicate(),
			"order": i
		}
		orders.append(dish_obj)

	orders = Utils.sort_by_attribute(orders, "order", "asc")

	for dish_obj in orders:
		bubble.add_child(dish_obj["dish"])
	_resize()


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
	select_dishes()
	bubble.show()
