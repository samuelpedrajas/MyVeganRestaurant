extends Node2D


var orders = []
var separation = 20
var dish_scenes = []


func select_dishes(menu):
	pass


func add_dish(dish):
	var bubble_size = $Bubble.get_size()
	var x_center = bubble_size.x / 2.0
	var n_children = $Bubble.get_child_count() + 1
	var new_bubble_h = separation

	$Bubble.add_child(dish)
	for child in $Bubble.get_children():
		new_bubble_h += child.get_height() + separation
	$Bubble.set_size(Vector2(bubble_size.x, new_bubble_h))

	var acc = 0
	for i in range($Bubble.get_child_count()):
		var child = $Bubble.get_child(i)
		var half = child.get_height() / 2.0
		acc += half + separation + child.get_y_offset() / 2.0
		child.set_position(Vector2(x_center, acc))
		acc += half - child.get_y_offset() / 2.0
