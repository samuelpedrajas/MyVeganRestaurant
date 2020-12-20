extends Node2D


func _ready():
	get_tree().set_pause(true)
	get_tree().get_root().connect("size_changed", self, "_on_size_changed")


func send_to_destination(item, origin):
	var destination = null
	var destinations = get_tree().get_nodes_in_group(item.get_destination())
	for _destination in destinations:
		if not _destination.is_busy():
			destination = _destination
			break

	if destination == null:
		print("No destination is available")
		return null

	origin.drop_item()
	destination.add_item(item)
	print(
		"%s was added to %s" % [
			item.get_reference(), item.get_destination()
		]
	)
	return destination


func send_to_plate(item, origin):
	var plates = get_tree().get_nodes_in_group(item.get_destination())
	var menu = $Menu
	print("select_plate_strategy not implemented yet")
	for plate in plates:
		var dish = menu.get_new_dish(plate.dish, item)
		if dish == null:
			continue
		origin.drop_item()
		plate.add_dish(dish)
		return
	print("No plates available for this item")


func use_item(item, origin):
	print("Using item: %s" % [item.get_reference()])
	var destination_name = item.get_destination()
	if destination_name == "None":
		print("Item %s has no destination" % item.get_reference())
		return

	if destination_name == "Plate":
		send_to_plate(item, origin)
	elif destination_name == "Platform":
		print("Platforms not implemented yet")
	else:
		send_to_destination(item, origin)

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
