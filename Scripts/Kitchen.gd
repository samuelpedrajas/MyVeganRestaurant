extends Control


var time = 90
var score = 0
onready var client_area = $Main/ClientArea

func _ready():
	client_area.prepare_game()
	self.time = $Main/ClientArea.max_time
	get_tree().set_pause(true)
	get_tree().get_root().connect("size_changed", self, "_on_size_changed")
	$HUD.set_time(time)
	$HUD.set_goal(client_area.calculated_goal)
	$Timer.start()
	_on_size_changed()


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


func _custom_client_sort(c1, c2):
	if c1.is_red() and c2.is_red():
		return c1.time_of_arrival <= c2.time_of_arrival
	elif c1.is_red() or c2.is_red():
		return c1.is_red()
	else:
		return c1.time_of_arrival <= c2.time_of_arrival


func _get_clients_sorted_by_priority():
	var clients = get_tree().get_nodes_in_group("Client")
	clients.sort_custom(self, "_custom_client_sort")
	return clients


func _select_plate(item):
	var menu = $Menu

	var clients = _get_clients_sorted_by_priority()
	var plates = get_tree().get_nodes_in_group(item.get_destination())
	var escenarios = {}
	var useless_new_item_escenarios = {}
	var created_dishes = []
	for plate in plates:
		var new_dish = menu.get_new_dish(plate.dish, item)
		if new_dish == null:
			continue

		created_dishes.append(new_dish)
		var escenario = [new_dish]
		for _plate in plates:
			if _plate.dish != null and _plate != plate:
				escenario.append(_plate.dish)

		var useless = true
		for client in clients:
			if client.accepts_dish(new_dish):
				useless = false
				break
		if useless:
			useless_new_item_escenarios[plate] = escenario
		else:
			escenarios[plate] = escenario

	if escenarios.size() == 0:
		escenarios = useless_new_item_escenarios
	elif escenarios.size() == 1:
		return escenarios.keys()[0]

	var selected_plates = escenarios.keys()
	for client in clients:
		var reward_deliveries = {}
		for plate in escenarios.keys():
			var escenario = escenarios[plate]
			reward_deliveries[plate] = 0.0
			for _dish in client.get_dishes():
				for dish in escenario.duplicate():
					if dish.reference == _dish.reference:
						reward_deliveries[plate] += dish.profit
						escenario.erase(dish)
						break
		var winners = []
		var max_reward_deliveries = reward_deliveries.values().max()
		for plate in reward_deliveries:
			var n = reward_deliveries[plate]
			if n == max_reward_deliveries:
				winners.append(plate)

		if winners != []:
			selected_plates = winners

		if winners.size() == 1:
			break
		else:
			var new_escenarios = {}
			for winner in winners:
				new_escenarios[winner] = escenarios[winner]
			escenarios = new_escenarios

	for dish in created_dishes:
		dish.free()

	if not selected_plates:
		return null

	return selected_plates[0]


func send_to_plate(item, origin):
	var menu = $Menu
	var plate = _select_plate(item)
	if plate != null:
		var dish = menu.get_new_dish(plate.dish, item)
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
		print("%s points losed" % item.discard_price)
		substract_score(item.discard_price)
		origin.drop_item()
		$Main/Bin.throw_item(item)
	else:
		send_to_destination(item, origin)


func _select_client(dish):
	var clients = _get_clients_sorted_by_priority()
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
	$Main.add_child(dish)
	dish.deliver(origin.get_throw_position())
	add_score(dish.profit)


func add_score(inc):
	score += inc
	$HUD.set_score(score)


func substract_score(inc):
	score -= inc
	score = max(0, score)
	$HUD.set_score(score)


### Signal Handlers ###

func _on_HUD_start_game():
	yield(get_tree(), "idle_frame")
	get_tree().set_pause(false)
	client_area.start()


func _on_size_changed():
	pass


func _on_Timer_timeout():
	time -= 1
	$HUD.set_time(time)
	if time == 0:
		get_tree().set_pause(true)
