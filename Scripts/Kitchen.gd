extends Node2D


func _ready():
	get_tree().set_pause(true)
	get_tree().get_root().connect("size_changed", self, "_on_size_changed")


func send_to_destination(item, origin):
	var destination_name = item.get_destination()
	var reference = item.get_reference()
	var destination = null
	var destinations = get_tree().get_nodes_in_group(destination_name)
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
			reference, destination_name
		]
	)


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


func send_to_platform(item, origin):
	var destination_name = item.get_destination()
	var reference = item.get_reference()
	var menu = $Menu
	var dish = menu.get_new_dish(null, item)
	origin.drop_item()
	origin.platform.add_dish(dish)
	print(
		"%s was added to %s" % [
			reference, destination_name
		]
	)


func use_item(item, origin):
	print("Using item: %s" % [item.get_reference()])
	var destination_name = item.get_destination()
	if destination_name == "None":
		print("Item %s has no destination" % item.get_reference())
		return

	if destination_name == "None":
		print("No destination available for %s" % item.get_reference())
	elif destination_name == "Plate":
		send_to_plate(item, origin)
	elif destination_name == "Platform":
		send_to_platform(item, origin)
	elif destination_name == "Bin":
		print("TODO: lose %s points" % item.discard_price)
		origin.drop_item()
		$Main/Bin.throw_item(item)
	else:
		send_to_destination(item, origin)


func _select_client(dish):
	var clients = get_tree().get_nodes_in_group("Client")
	for client in clients:
		if client.accepts_dish(dish):
			return client
	return null


func deliver(dish, origin):
	var client = _select_client(dish)
	if client == null:
		print("No client accepts this dish")
		return
	origin.drop_item()
	client.receive_dish(dish)
	dish.deliver(Vector2())


### Signal Handlers ###

func _on_HUD_start_game():
	yield(get_tree(), "idle_frame")
	get_tree().set_pause(false)
	$Main/ClientArea.start()


func _on_size_changed():
	var screen_size = OS.get_screen_size()
	var viewport_size = get_viewport_rect().size
	var position_offset = (viewport_size - screen_size) / 2.0
	print("Resizing Kitchen")
	set_position(position_offset)
	$Main.set_global_position(
		Vector2(
			$Main.get_global_position().x,
			viewport_size.y - $Main.texture.get_size().y / 2.0
		)
	)
