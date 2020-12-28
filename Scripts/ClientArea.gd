extends Control


export(int) var max_n_clients = 5
export(NodePath) onready var menu = get_node(menu)

var client_scene = preload("res://Scenes/Client.tscn")

var rng = RandomNumberGenerator.new()
var pending_clients = 0
var position_availability = []

var max_time = 90  # TODO: syncronise with Kitchen
var max_arrival_time = 3.0  # TODO: syncronise with Client
var average_time_for_client = 6.0
var average_reward_for_client = 150.0
var category_probabilities = [0.4, 0.8, 0.5]
var max_orders = 4

var patience_multiplier = 3.0
var base_variability = 0.5
var added_variability = 3.0
var added_variability_percentage = 0.4
var maximums = [0.8]
var minimums = [0.2]

# calculated
var usable_time = max_time - average_time_for_client - max_arrival_time - added_variability
var guaranteed_coins = null
var order_lists = []
var timeout_seconds = []


func start():
	rng.randomize()
	_prepare_game()
#	for _i in range(max_n_clients):
#		position_availability.append(true)
#	for _i in range(max_n_clients):
#		new_client()
#		yield(get_tree().create_timer(2.0), "timeout")


func _prepare_game():
	# TODO: revisar si podría quedarse colgado: asignar demasiadas bebidas
	# y complementos y ya no poder superar el goal
	var average_client_number = usable_time / average_time_for_client
	var calculated_goal = average_client_number * average_reward_for_client
	var orders = []
	for _i in range(0, average_client_number):
		orders.append([])
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

	# build timeout_seconds
	average_time_for_client = usable_time / order_lists.size()
	timeout_seconds = []
	for _i in range(0, order_lists.size() - 1):
		timeout_seconds.append(average_time_for_client)

	var num_added_var = floor(
		added_variability_percentage * timeout_seconds.size()
	)
	if int(num_added_var) % 2 != 0:
		num_added_var -= 1

	var addition = 0
	var var_limit = min(floor(timeout_seconds.size() / 2.0) * 2, num_added_var)
	# first is time 0
	for i in range(0, var_limit):
		if i % 2 == 0:
			addition = rng.randf_range(base_variability, added_variability)
			timeout_seconds[i] += addition
		else:
			timeout_seconds[i] -= addition

	var num_var = timeout_seconds.size()
	if int(num_var - var_limit) % 2 != 0:
		num_var -= 1

	for i in range(var_limit, num_var):
		if i % 2 == 0:
			addition = rng.randf_range(0, base_variability)
			timeout_seconds[i] += addition
		else:
			timeout_seconds[i] -= addition

	# maximums and minimums
	var max_start = []
	var clients_per_maximum = floor(var_limit / maximums.size() / 2.0)
	var min_start = []
	var clients_per_minimum = floor(var_limit / minimums.size() / 2.0)
	for maximum in maximums:
		max_start.append(
			floor(
				(maximum * timeout_seconds.size()) - (clients_per_maximum / 2.0)
			)
		)
	for minimum in minimums:
		min_start.append(
			floor(
				(minimum * timeout_seconds.size()) - (clients_per_minimum / 2.0)
			)
		)

	timeout_seconds.sort()
	var total_highests = clients_per_maximum * maximums.size()
	var highests = timeout_seconds.slice(0, total_highests - 1)
	var total_lowests = clients_per_minimum * minimums.size()
	var starting_lowests = timeout_seconds.size() - total_lowests
	var lowests = timeout_seconds.slice(
		starting_lowests, timeout_seconds.size()
	)
	var rest = timeout_seconds.slice(total_highests, starting_lowests - 1)

	rest.shuffle()

	print(timeout_seconds)
	print("HIGHESTS")
	print(total_highests)
	print(highests)
	print("LOWESTS")
	print(total_lowests)
	print(lowests)
	print("REST")
	print(rest)

	timeout_seconds = [0]
	var max_countdown = 0
	var min_countdown = 0
	var i = 0
	while highests or lowests or rest:
		if i in max_start:
			max_countdown = clients_per_maximum
		if i in min_start:
			min_countdown = clients_per_minimum
		if max_countdown > 0 and highests:
			timeout_seconds.append(highests.pop_back())
			max_countdown -= 1
			i += 1
			continue
		if min_countdown > 0 and lowests:
			timeout_seconds.append(lowests.pop_back())
			min_countdown -= 1
			i += 1
			continue
		if rest:
			timeout_seconds.append(rest.pop_back())
			i += 1

	print("NO ACCUMULATION")
	print(timeout_seconds)

	# accumulate timeouts
	for _i in range(2, timeout_seconds.size()):
		timeout_seconds[_i] += timeout_seconds[_i - 1]

	print("FINAL TIMEOUTS:")
	print(timeout_seconds)
	print("TOTAL: %s" % [timeout_seconds.size()])

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
	print("MAXIMUM START: %s" % [max_start])
	print("MINIMUM START: %s" % [min_start])
	print("CLIENTS PER MAXIMUM: %s" % [str(clients_per_maximum)])
	print("CLIENTS PER MINIMUM: %s" % [str(clients_per_minimum)])


func new_client():
	var client = client_scene.instance()
	client.setup(menu, rng)
	add_child(client)
	client.walk_in(_get_new_client_position())


func _get_new_client_position():
	var area_size = get_size()
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
	var x_pos = area_size.x / (max_n_clients + 1) * (pos + 1)
	return Vector2(
		x_pos, area_size.y
	)
