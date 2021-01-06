extends Node2D


export(NodePath) onready var kitchen = get_node(kitchen)
export(String) var destination_group = null
onready var ingredient = $Ingredient


func _send_to_group():
	var destination = null
	var destinations = get_tree().get_nodes_in_group(destination_group)
	for _destination in destinations:
		if not _destination.is_busy():
			destination = _destination
			break

	if destination == null:
		print("No destination is available")
		return null

	destination.add_item(self.ingredient.duplicate())
	print(
		"%s was added to %s" % [
			self.ingredient.reference, destination.get_name()
		]
	)


func _on_ClickableArea_pressed():
	if destination_group == null:
		var plate = kitchen.select_plate(self.ingredient)
		if plate != null:
			plate.add_ingredient(ingredient.duplicate())
		else:
			print("No plates available for %s" % [get_name()])
	else:
		_send_to_group()
