extends Node2D


func get_new_delivery_name(delivery, ingredient):
	var new_delivery = _get_new_delivery(delivery, ingredient)
	if new_delivery == null:
		return null
	return new_delivery.reference


func get_new_delivery(delivery, ingredient):
	var new_delivery = _get_new_delivery(delivery, ingredient)
	if new_delivery == null:
		return null
	return new_delivery.duplicate()


func get_delivery(reference):
	for category in get_children():
		for _delivery in category.get_children():
			if _delivery.reference == reference:
				return _delivery
	return null


func get_delivery_category(reference):
	for category in get_children():
		for _delivery in category.get_children():
			if _delivery.reference == reference:
				return category.get_name()
	return null


func _get_new_delivery(delivery, ingredient):
	var ingredients = []
	if delivery != null:
		ingredients += delivery.ingredients
	ingredients.append(ingredient.get_level_reference())

	for category in get_children():
		for _delivery in category.get_children():
			if Utils.arrays_have_same_content(ingredients, _delivery.ingredients):
				return _delivery
	return null
