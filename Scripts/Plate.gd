extends Node2D


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
