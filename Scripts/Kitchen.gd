extends Control


var time = 90
var score = 0
onready var client_area = $Main/ClientArea
onready var menu = $Menu

func _ready():
	client_area.prepare_game()
	self.time = $Main/ClientArea/LevelConfig.max_time
	get_tree().set_pause(true)
	get_tree().get_root().connect("size_changed", self, "_on_size_changed")
	$HUD.set_time(time)
	$HUD.set_goal(client_area.calculated_goal)
	$Timer.start()
	_on_size_changed()


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


func select_plate(item):
	var clients = _get_clients_sorted_by_priority()
	var plates = get_tree().get_nodes_in_group("Plate")
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
		get_tree().set_pause(true)
