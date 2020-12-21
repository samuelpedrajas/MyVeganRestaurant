extends Node2D


onready var bubble = $Sprite/Bubble
var max_orders = 4
var separation = 30

var menu
var rng

var bubble_initial_position


func _ready():
	select_dishes()


func setup(menu, rng):
	self.menu = menu
	self.rng = rng


func select_dishes():
	# TODO: agrupados por categoría
	# TODO2: tener en cuenta sólo los deliverables
	var categories = menu.get_children()
	var n_categories = menu.get_child_count()
	var n_orders = rng.randi_range(1, max_orders)
	var orders = []
	for _unused in range(n_orders):
		var i = rng.randi_range(0, n_categories - 1)
		var category = categories[i]
		var n_dishes = category.get_child_count()
		var j = rng.randi_range(0, n_dishes - 1)
		var dish = category.get_child(j)
		orders.append(dish.duplicate())

	for dish in orders:
		bubble.add_child(dish)
	_resize()


func _resize():
	var init_position = bubble.get_position()
	var bubble_size = bubble.get_size()
	var x_center = bubble_size.x / 2.0
	var new_bubble_h = separation

	for child in bubble.get_children():
		new_bubble_h += child.get_height() + separation

	bubble.set_size(Vector2(bubble_size.x, new_bubble_h))
	bubble.set_position(init_position - Vector2(
		0, new_bubble_h * bubble.get_scale().y
	))

	var acc = 0
	for i in range(bubble.get_child_count()):
		var child = bubble.get_child(i)
		var half = child.get_height() / 2.0
		acc += half + separation + child.get_y_offset() / 2.0
		child.set_position(Vector2(x_center, acc))
		acc += half - child.get_y_offset() / 2.0
