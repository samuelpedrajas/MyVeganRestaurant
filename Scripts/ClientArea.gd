extends Control


export(int) var max_n_clients = 5
export(NodePath) onready var menu = get_node(menu)

var client_scene = preload("res://Scenes/Client.tscn")

var rng = RandomNumberGenerator.new()
var num_clients = 0
var current_time = 0
var position_availability = []
var current_n_clients = 0


export(float) var max_time = 600
export(float) var max_arrival_time = 3.0
export(float) var average_time_for_client = 3.0
export(float) var average_reward_for_client = 120.0
export(Array) var category_probabilities = [0.6, 0.8, 0.6]
export(int) var max_orders = 4

export(float) var seconds_gained_on_delivery = 3.0 * average_time_for_client
export(float) var patience = 10.0 * average_time_for_client
export(float) var base_variability = 0.5
export(float) var added_variability = 2.0
export(float) var added_variability_percentage = 0.4
export(Array) var maximums = [0.8]
export(Array) var minimums = [0.2]

export(Dictionary) var price_override = {
	"Fries": 50,
	"SimpleBurger": 75,
	"TomatoBurger": 100,
	"LettuceBurger": 100,
	"CompleteBurger": 125,
	"Cola": 25
}
export(Dictionary) var discard_price_override = {
	"Fries": 25,
	"BurgerBread": 10,
	"SimpleBurger": 50,
	"TomatoBurger": 75,
	"LettuceBurger": 75,
	"CompleteBurger": 100,
	"Cola": 12
}

# calculated
var usable_time = null
var guaranteed_coins = null
var order_lists = []
var timeout_seconds = []
var average_client_number = null
var calculated_goal = null


func start():
	for _i in range(max_n_clients):
		position_availability.append(true)
	new_client()
	$Timer.start()
	print("SECONDS: %s" % [current_time])


func _override_prices():
	for category in menu.get_children():
		for dish in category.get_children():
			if dish.deliverable:
				dish.profit = price_override[dish.reference]
			dish.discard_price = discard_price_override[dish.reference]


func _build_order_lists():
	# TODO: revisar si podría quedarse colgado: asignar demasiadas bebidas
	# y complementos y ya no poder superar el goal
	var orders = Utils.initialise_array(average_client_number, [])

	guaranteed_coins = 0
	# dish distribution
	while guaranteed_coins < calculated_goal:
		var categories = menu.get_children()
		var n_categories = menu.get_child_count()
		for i in range(0, average_client_number):
			for j in range(0, n_categories):
				var skip = rng.randf() < 1.0 - category_probabilities[j]
				if skip or orders[i].size() >= max_orders:
					continue
				var category = categories[j]
				# get deliverable dishes
				var dishes = []
				for dish in category.get_children():
					if dish.deliverable:
						dishes.append(dish)
				var n_dishes = dishes.size()
				var selected = rng.randi_range(0, n_dishes - 1)
				var dish_obj = {
					"dish": dishes[selected].duplicate(),
					"order": j
				}
				orders[i].append(dish_obj)
				guaranteed_coins += dish_obj["dish"].profit
			if guaranteed_coins >= calculated_goal:
				break

	# sort and assign to order_lists
	for i in range(0, average_client_number):
		if orders[i] == []:
			continue
		orders[i] = Utils.sort_by_attribute(orders[i], "order", "asc")
		order_lists.append([])
		for _order in orders[i]:
			order_lists[-1].append(_order["dish"])


func _build_timeouts():
	average_time_for_client = usable_time / order_lists.size()

	# exclude 0
	timeout_seconds = Utils.initialise_array(
		order_lists.size() - 1, average_time_for_client
	)

	# num clients with additional variability
	var num_added_var = floor(
		added_variability_percentage * timeout_seconds.size()
	)

	# we need it to be even
	if int(num_added_var) % 2 != 0:
		num_added_var -= 1

	# apply additional variability
	var addition = 0
	for i in range(0, num_added_var):
		if i % 2 == 0:
			addition = rng.randf_range(base_variability, added_variability)
			timeout_seconds[i] += addition
		else:
			timeout_seconds[i] -= addition

	# calculate base variability upper limit (must be even too)
	var limit_base_var = timeout_seconds.size()
	if int(limit_base_var - num_added_var) % 2 != 0:
		limit_base_var -= 1

	# apply base variability
	addition = 0
	for i in range(num_added_var, limit_base_var):
		if i % 2 == 0:
			addition = rng.randf_range(0, base_variability)
			timeout_seconds[i] += addition
		else:
			timeout_seconds[i] -= addition

	# maximums and minimums
	var max_start = []
	var clients_per_maximum = floor(num_added_var / maximums.size() / 2.0)
	var min_start = []
	var clients_per_minimum = floor(num_added_var / minimums.size() / 2.0)
	for maximum in maximums:
		max_start.append(
			min(floor(
				(maximum * timeout_seconds.size()) - (clients_per_maximum / 2.0)
			), usable_time)
		)
	for minimum in minimums:
		min_start.append(
			max(floor(
				(minimum * timeout_seconds.size()) - (clients_per_minimum / 2.0)
			), 1)
		)

	print("MAXIMUM START: %s" % [max_start])
	print("MINIMUM START: %s" % [min_start])
	print("CLIENTS PER MAXIMUM: %s" % [str(clients_per_maximum)])
	print("CLIENTS PER MINIMUM: %s" % [str(clients_per_minimum)])

	# get fastests, slowests and rest
	timeout_seconds.sort()
	var total_fastests = clients_per_maximum * maximums.size()
	var fastests = timeout_seconds.slice(0, total_fastests - 1)
	var total_slowests = clients_per_minimum * minimums.size()
	var starting_slowests = timeout_seconds.size() - total_slowests
	var slowests = timeout_seconds.slice(
		starting_slowests, timeout_seconds.size()
	)
	var rest = timeout_seconds.slice(total_fastests, starting_slowests - 1)

	rest.shuffle()

	print(timeout_seconds)
	print("FASTESTS (%s): %s" % [total_fastests, fastests])
	print("SLOWESTS (%s): %s" % [total_slowests, slowests])
	print("REST: %s" % [rest])

	timeout_seconds = [0]
	var max_countdown = 0
	var min_countdown = 0
	var i = 1  # 0 is skipped
	while fastests or slowests or rest:
		if i in max_start:
			max_countdown += clients_per_maximum
		if i in min_start:
			min_countdown += clients_per_minimum
		if max_countdown > 0 and fastests:
			timeout_seconds.append(fastests.pop_back())
			max_countdown -= 1
			i += 1
			continue
		if min_countdown > 0 and slowests:
			timeout_seconds.append(slowests.pop_back())
			min_countdown -= 1
			i += 1
			continue
		if rest:
			timeout_seconds.append(rest.pop_back())
			i += 1

	print("NOT ACCUMULATED TIMEOUTS: %s" % [timeout_seconds])

	# accumulate timeouts
	for _i in range(1, timeout_seconds.size()):
		timeout_seconds[_i] = round(timeout_seconds[_i])
		timeout_seconds[_i] += int(timeout_seconds[_i - 1])


func prepare_game():
	rng.randomize()
	self.usable_time = (max_time - average_time_for_client - max_arrival_time)
	self.average_client_number = ceil(usable_time / average_time_for_client)
	self.calculated_goal = average_client_number * average_reward_for_client

	_override_prices()
	_build_order_lists()
	_build_timeouts()

	print("CALCULATED GOAL: %s" % [str(calculated_goal)])
	print("GUARANTEED COINS: %s" % [str(guaranteed_coins)])
	print("CALCULATED AVERAGE CLIENT NUMBER: %s" % [str(average_client_number)])
	print("AVG. TIME FOR CLIENT: %s" % [str(average_time_for_client)])
	print("FINAL ORDER LIST NUMBER: %s" % [str(order_lists.size())])
	print("FINAL ORDER LISTS:")
	for _orders in order_lists:
		var references = []
		var total = 0.0
		for _order in _orders:
			total += _order.profit
			references.append(
				"%s = %s" % [
					_order.reference, str(_order.profit)
				]
			)
		print("Total: %s, References: %s" % [str(total), str(references)])
	print("FINAL TIMEOUTS:")
	print(timeout_seconds)
	print("TOTAL: %s" % [timeout_seconds.size()])


func select_random_dishes():
	var categories = menu.get_children()
	var n_categories = menu.get_child_count()
	var n_orders = rng.randi_range(1, max_orders)
	var orders = []
	for _unused in range(n_orders):
		var i = rng.randi_range(0, n_categories - 1)
		var category = categories[i]
		# get deliverable dishes
		var dishes = []
		for dish in category.get_children():
			if dish.deliverable:
				dishes.append(dish)
		var n_dishes = dishes.size()
		var j = rng.randi_range(0, n_dishes - 1)
		var dish_obj = {
			"dish": dishes[j].duplicate(),
			"order": i
		}
		orders.append(dish_obj)

	orders = Utils.sort_by_attribute(orders, "order", "asc")
	var order_list = []
	for _order in orders:
		order_list.append(_order["dish"])
	return order_list


func client_served(client):
	position_availability[client.idx] = true
	current_n_clients -= 1
	if current_n_clients < 1:
		new_client()


func client_angry(client):
	position_availability[client.idx] = true
	current_n_clients -= 1
	if current_n_clients < 1:
		new_client()


func new_client():
	var idx = _get_new_client_position()
	if idx == null:
		print("THERE'S NO SPACE FOR NEW CLIENTS!")
		return
	var new_client_position = aval_position_to_vector(idx)
	var dishes
	if not order_lists:
		dishes = select_random_dishes()
		print("RANDOMLY SELECTED DISHES: %s" % [dishes])
	else:
		timeout_seconds.pop_front()
		dishes = order_lists.pop_front()
		print("DISHES SELECTED FROM ORDER LIST: %s" % [dishes])

	var client = client_scene.instance()
	client.setup(
		idx, current_time, dishes, max_arrival_time, patience,
		seconds_gained_on_delivery, rng
	)
	add_child(client)
	client.connect("served", self, "client_served")
	client.connect("leaving_angry", self, "client_angry")
	client.walk_in(new_client_position)
	num_clients += 1
	current_n_clients += 1
	print("NEW CLIENT (TOTAL: %s)" % [num_clients])
	print("CURRENT IN BOARD: %s" % [current_n_clients])


func _get_new_client_position():
	var available_positions = []
	for i in range(max_n_clients):
		var available = position_availability[i]
		if available:
			available_positions.append(i)

	if not available_positions:
		return null

	var i = rng.randi_range(0, available_positions.size() - 1)
	var pos = available_positions[i]
	position_availability[pos] = false
	return pos


func aval_position_to_vector(pos):
	var area_size = get_size()
	var x_pos = area_size.x / (max_n_clients + 1) * (pos + 1)
	return Vector2(
		x_pos, area_size.y
	)


func _on_Timer_timeout():
	current_time += 1
	if int(current_time) in timeout_seconds:
		print("TIMEOUT SECOND!")
		new_client()
	print("SECONDS: %s" % [current_time])
