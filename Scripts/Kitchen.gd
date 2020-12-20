extends Node2D


func _ready():
	get_tree().set_pause(true)
	get_tree().get_root().connect("size_changed", self, "_on_size_changed")


func select_destination(item):
	var destinations = get_tree().get_nodes_in_group(item.get_destination())
	destinations = Utils.sort_by_attribute(destinations, "order")
	for destination in destinations:
		if not destination.is_busy():
			return destination
	return null

func use_item(item, origin):
	print("Using item: %s" % [item.get_reference()])
	var destination_name = item.get_destination()
	if destination_name == "None":
		print("Item %s has no destination" % item.get_reference())
		return

	if destination_name == "Plate":
		print("Plates not implemented yet")
	elif destination_name == "Platform":
		print("Platforms not implemented yet")
	else:
		var destination = select_destination(item)
		if destination == null:
			print("No destination is available")
		else:
			origin.drop_item()
			destination.add_item(item)
			print(
				"%s was added to %s" % [item.get_reference(), destination_name]
			)

### Signal Handlers ###

func _on_HUD_start_game():
	yield(get_tree(), "idle_frame")
	get_tree().set_pause(false)


func _on_size_changed():
	var screen_size = OS.get_screen_size()
	var viewport_size = get_viewport_rect().size
	var position_offset = (viewport_size - screen_size) / 2.0
	print("Resizing Kitchen")
	set_position(position_offset)
	$Table.set_global_position(
		Vector2(
			$Table.get_global_position().x,
			viewport_size.y - $Table.texture.get_size().y / 2.0
		)
	)
