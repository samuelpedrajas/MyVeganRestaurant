extends Node2D


export(NodePath) onready var kitchen = get_node(kitchen)
export(String) var destination_group = null
export(NodePath) onready var ingredient = get_node(ingredient)

var upgrade = 0


func set_config(ingredient_level):
	self.upgrade = ingredient_level
	_play_default_animation()
	print("%s upgraded" % [get_name()])


func _send_to_group():
	var destination = null
	var destinations = get_tree().get_nodes_in_group(destination_group)
	for _destination in destinations:
		if _destination.is_visible() and not _destination.is_busy():
			destination = _destination
			break

	if destination == null:
		print("No destination is available")
		return null

	destination.add_item(self.ingredient.clone())
	print(
		"%s was added to %s" % [
			self.ingredient.reference, destination.get_name()
		]
	)


func _on_ClickableArea_pressed():
	if destination_group == null:
		var plate = kitchen.select_plate(self.ingredient)
		if plate != null:
			plate.add_ingredient(ingredient.clone())
		else:
			print("No plates available for %s" % [get_name()])
	else:
		_send_to_group()


func _play_default_animation():
	var anim_name = "default_animation_%s" % [str(self.upgrade)]
	$AnimationPlayer.play(anim_name)
