extends Node2D


export(NodePath) onready var kitchen = get_node(kitchen)
export(bool) var is_platform = false
export(Vector2) var placeholder_position

var dish = null
var double_click_threshold = 0.5
var double_click = false


func _ready():
	if placeholder_position != null:
		$Placeholder.set_position(placeholder_position)


func add_ingredient(ingredient):
	var new_dish = kitchen.menu.get_new_dish(dish, ingredient)
	add_dish(new_dish)


func add_dish(_dish):
	for child in $Placeholder.get_children():
		child.queue_free()
	var old_dish_name = "None"
	if  self.dish != null:
		old_dish_name = self.dish.reference
	self.dish = _dish
	$Placeholder.add_child(_dish)
	print("Plate: %s ---> %s" % [old_dish_name, _dish.reference])


func get_throw_position():
	return $Placeholder.get_global_position()


func drop_item():
	$Placeholder.remove_child(self.dish)
	self.dish = null


func _on_ClickableArea_pressed():
	deliver()


func deliver():
	if dish == null:
		pass
	elif double_click:
		kitchen.throw_to_bin(dish, self)
		double_click = false
	elif is_platform:
		kitchen.deliver(dish, self)
	else:
		var useless = kitchen.is_useless(dish)
		if useless and dish.throwable:
			double_click = true
			$DoubleClick.start()
		else:
			kitchen.deliver(dish, self)


func _on_DoubleClick_timeout():
	double_click = false


func _on_DoubleClick_ready():
	$DoubleClick.set_wait_time(double_click_threshold)
