extends Node2D


func get_new_dish_name(dish, ingredient):
	var new_dish = _get_new_dish(dish, ingredient)
	if new_dish == null:
		return null
	return new_dish.reference


func get_new_dish(dish, ingredient):
	var new_dish = _get_new_dish(dish, ingredient)
	if new_dish == null:
		return null
	return new_dish.duplicate()


func get_dish(reference):
	for category in get_children():
		for _dish in category.get_children():
			if _dish.reference == reference:
				return _dish
	return null


func get_dish_category(reference):
	for category in get_children():
		for _dish in category.get_children():
			if _dish.reference == reference:
				return category.get_name()
	return null


func _get_new_dish(dish, ingredient):
	var ingredients = []
	if dish != null:
		ingredients += dish.ingredients
	ingredients.append(ingredient.get_reference())

	for category in get_children():
		for _dish in category.get_children():
			if Utils.arrays_have_same_content(ingredients, _dish.ingredients):
				return _dish
	return null
