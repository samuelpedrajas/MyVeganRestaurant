extends Control


signal close_request


var time = 90  # will be overrided
var score = 0
onready var client_area = $Main/ClientArea
onready var menu = $Menu


func open_screen(level_config, upgrades, status):
	for group_name in level_config.unavailable_nodes:
		var nodes = get_tree().get_nodes_in_group(group_name)
		for node in nodes:
			node.hide()
	_configure_upgrades(upgrades, status)
	client_area.prepare_game(level_config)
	self.time = level_config.max_time
	get_tree().set_pause(true)
	get_tree().get_root().connect("size_changed", self, "_on_size_changed")
	$HUD.set_time(time)
	$HUD.set_goal(client_area.calculated_goal)
	$Timer.start()
	_on_size_changed()
	show()


func _upgrade_group(group_name, status, upgrades_dict=null):
	var upgrades = null
	var n_slots = 99
	if upgrades_dict != null:
		upgrades = upgrades_dict[group_name]
		if "Slots" in upgrades[status]:
			n_slots = upgrades[status]["Slots"]

	var nodes = get_tree().get_nodes_in_group(group_name)
	for i in range(nodes.size()):
		if i == n_slots:
			break
		var node = nodes[i]
		if group_name != "Plate":
			node.set_upgrade(status, upgrades)
		node.show()


func _configure_upgrades(upgrades, status):
	# Upgrade machines and ingredient providers
	var group_names = ["Machines", "IngredientSources"]
	for group_name in group_names:
		var upgrades_dict = null
		if group_name in upgrades:
			upgrades_dict = upgrades[group_name]
		var status_dict = status[group_name]
		for item_name in status_dict.keys():
			var _status = status_dict[item_name]
			_upgrade_group(item_name, _status, upgrades_dict)

	# Unlock plates
	_upgrade_group("Plate", status["Plate"], upgrades)


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


func is_useless(delivery):
	var clients = get_tree().get_nodes_in_group("Client")
	for client in clients:
		if client.accepts_delivery(delivery):
			return false
	return true


func _get_plates():
	var plates = []
	for plate in get_tree().get_nodes_in_group("Plate"):
		if plate.is_visible():
			plates.append(plate)
	return plates


func select_plate(item):
	var clients = _get_clients_sorted_by_priority()
	var plates = _get_plates()
	var escenarios = {}
	var useless_new_item_escenarios = {}
	var created_deliveries = []
	for plate in plates:
		var new_delivery = menu.get_new_delivery(plate.delivery, item)
		if new_delivery == null:
			continue

		created_deliveries.append(new_delivery)
		var escenario = [new_delivery]
		for _plate in plates:
			if _plate.delivery != null and _plate != plate:
				escenario.append(_plate.delivery)

		var useless = is_useless(new_delivery)
		for client in clients:
			if client.accepts_delivery(new_delivery):
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
			for _delivery in client.get_deliveries():
				for delivery in escenario.duplicate():
					if delivery.reference == _delivery.reference:
						reward_deliveries[plate] += client_area.get_price(delivery.reference)
						escenario.erase(delivery)
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

	for delivery in created_deliveries:
		delivery.free()

	if not selected_plates:
		return null

	return selected_plates[0]


func _select_client(delivery):
	var clients = _get_clients_sorted_by_priority()
	for client in clients:
		if client.accepts_delivery(delivery):
			return client
	return null


func deliver(delivery, origin):
	var client = _select_client(delivery)
	if client == null:
		print("No client accepts this delivery")
		return
	origin.drop_item()
	client.receive_delivery(delivery)
	$Main.add_child(delivery)
	delivery.deliver(origin.get_throw_position())
	add_score(client_area.get_price(delivery.reference))


func throw_to_bin(item, origin):
	if not item.throwable:
		print("This item is not throwable")
		return

	print("%s points losed" % client_area.get_discard_price(item.reference))
	substract_score(client_area.get_discard_price(item.reference))
	origin.drop_item()
	$Main.add_child(item)
	$Main/Bin.throw_item(item, origin)


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
		get_tree().get_root().set_disable_input(true)
		emit_signal("close_request")
