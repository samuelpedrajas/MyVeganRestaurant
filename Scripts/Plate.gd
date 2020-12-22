extends Node2D


export(NodePath) onready var kitchen = get_node(kitchen)

var dish = null


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


func _on_ClickableArea_clicked():
	if dish != null:
		kitchen.deliver(dish, self)
