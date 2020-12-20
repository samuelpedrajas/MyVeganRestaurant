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


func _get_new_dish(dish, ingredient):
	var ingredients = []
	if dish != null:
		ingredients += dish.ingredients
	ingredients.append(ingredient.get_reference())

	for dish in get_children():
		if Utils.arrays_have_same_content(ingredients, dish.ingredients):
			return dish
	return null
