extends Control


export(int) var max_n_clients = 4
export(NodePath) onready var menu = get_node(menu)

var client_scene = preload("res://Scenes/Client.tscn")

var rng = RandomNumberGenerator.new()
var num_clients = 0
var current_time = 0
var position_availability = []
var current_n_clients = 0
var max_orders = 4

# calculated
var usable_time = null
var guaranteed_coins = null
var order_lists = []
var timeout_seconds = []
var average_client_number = null
var calculated_goal = null
var average_time_for_client = null


func start():
	for _i in range(max_n_clients):
		position_availability.append(true)
	new_client()
	$Timer.start()
	print("SECONDS: %s" % [current_time])


func get_price(dish_ref):
	return $LevelConfig.prices[dish_ref]


func get_discard_price(dish_ref):
	return $LevelConfig.discard_prices[dish_ref]


func _get_random_dish_from_category(cat):
	var probabilities = $LevelConfig.dishes_probability[cat]
	return Utils.weighted_random(
		probabilities.keys(),
		probabilities,
		rng
	)


func _get_random_category():
	var probabilities = $LevelConfig.category_probability
	return Utils.weighted_random(
		probabilities.keys(),
		probabilities,
		rng
	)


func _sort_dishes_by_category(order):
	var orders_aux = []
	for dish_ref in order:
		var cat = menu.get_dish_category(dish_ref)
		orders_aux.append({
			"dish": dish_ref,
			"order": $LevelConfig.category_order[cat]
		})
	orders_aux = Utils.sort_by_attribute(orders_aux, "order", "asc")

	var result = []
	for _order in orders_aux:
		result.append(_order["dish"])

	return result


func _build_order_lists():
	var orders = Utils.initialise_array(average_client_number, [])
	var prices = $LevelConfig.prices
	var dishes_probability = $LevelConfig.dishes_probability
	var category_probability = $LevelConfig.category_probability

	guaranteed_coins = 0

	# dish distribution
	while guaranteed_coins < calculated_goal:
		for i in range(0, average_client_number):
			if orders[i].size() == max_orders:
				continue
			var cat = _get_random_category()
			var selected_dish_ref = _get_random_dish_from_category(cat)
			var profit = prices[selected_dish_ref]

			if guaranteed_coins + profit > calculated_goal:
				var diff = (guaranteed_coins + profit) - calculated_goal
				var sorted_dish_refs = Utils.dict_to_sorted_tuple_list(
					prices, "asc"
				)
				for t in sorted_dish_refs:
					var dish_ref = t[0]
					cat = menu.get_dish_category(dish_ref)
					if category_probability[cat] == 0:
						continue
					if dishes_probability[cat][dish_ref] == 0:
						continue
					var new_profit = prices[dish_ref]
					if new_profit > diff:
						profit = new_profit
						selected_dish_ref = dish_ref
						break

			orders[i].append(selected_dish_ref)
			guaranteed_coins += profit
			if guaranteed_coins >= calculated_goal:
				break

	# sort and assign to order_lists
	for i in range(0, average_client_number):
		if orders[i] == []:
			continue

		var final_order = []
		for dish_ref in _sort_dishes_by_category(orders[i]):
			final_order.append(menu.get_dish(dish_ref).duplicate())

		order_lists.append(final_order)
	order_lists.shuffle()


func _build_timeouts():
	average_time_for_client = usable_time / order_lists.size()
	var base_variability = $LevelConfig.base_variability
	var added_variability = $LevelConfig.added_variability

	# exclude 0
	timeout_seconds = Utils.initialise_array(
		order_lists.size() - 1, average_time_for_client
	)

	# num clients with additional variability
	var num_added_var = floor(
		$LevelConfig.added_variability_percentage * timeout_seconds.size()
	)

	# apply additional variability
	var total = 0
	for i in range(0, num_added_var):
		var substraction = rng.randf_range(
			base_variability, added_variability
		)
		timeout_seconds[i] -= substraction
		total += substraction

	var limit_base_var = timeout_seconds.size()
	var num_remaining = int(limit_base_var - num_added_var)
	if num_remaining > 0:
		# apply base variability
		var addition = null
		var compensation = float(total) / float(num_remaining)
		for i in range(num_added_var, limit_base_var):
			if addition == null:
				addition = rng.randf_range(0, base_variability)
				timeout_seconds[i] += addition
			else:
				timeout_seconds[i] -= addition
				addition = null
			timeout_seconds[i] += compensation

	# maximums
	var maximums = $LevelConfig.maximums
	var max_start = []
	var clients_per_maximum = 0
	if maximums.size() > 0:
		clients_per_maximum = floor(num_added_var / maximums.size())
	if clients_per_maximum > 0:
		for maximum in maximums:
			max_start.append(
				max(
					round(
						maximum * timeout_seconds.size() - clients_per_maximum
					), 0
				) + 1
			)

	print("MAXIMUM START: %s" % [max_start])
	print("CLIENTS PER MAXIMUM: %s" % [str(clients_per_maximum)])

	# get fastests and rest
	timeout_seconds.sort()
	var total_fastests = clients_per_maximum * maximums.size()
	var fastests = []
	var rest
	if total_fastests > 0:
		fastests = timeout_seconds.slice(0, total_fastests - 1)
		rest = timeout_seconds.slice(total_fastests, timeout_seconds.size())
		fastests.append(fastests.pop_front())  # better shuffle ...
		fastests.shuffle()
	else:
		rest = timeout_seconds
	rest.shuffle()

	print("FASTESTS (%s)" % [total_fastests])

	timeout_seconds = [0]
	var max_countdown = 0
	var i = 1  # 0 is skipped
	while fastests or rest:
		if i in max_start:
			max_countdown += clients_per_maximum
		if max_countdown > 0 and fastests:
			timeout_seconds.append(fastests.pop_back())
			max_countdown -= 1
		elif rest:
			timeout_seconds.append(rest.pop_back())
		i += 1

	# accumulate timeouts
	for _i in range(1, timeout_seconds.size()):
		timeout_seconds[_i] = round(timeout_seconds[_i])
		timeout_seconds[_i] += int(timeout_seconds[_i - 1])


func prepare_game():
	var max_time = $LevelConfig.max_time
	var max_arrival_time = $LevelConfig.max_arrival_time
	var average_reward_for_client = $LevelConfig.average_reward_for_client
	average_time_for_client = $LevelConfig.average_time_for_client

	rng.randomize()
	self.usable_time = (
		max_time - average_time_for_client - max_arrival_time
	)
	self.average_client_number = ceil(usable_time / average_time_for_client)
	self.calculated_goal = average_client_number * average_reward_for_client

	_build_order_lists()
	_build_timeouts()

	print("CALCULATED GOAL: %s" % [str(calculated_goal)])
	print("GUARANTEED COINS: %s" % [str(guaranteed_coins)])
	print("CALCULATED AVERAGE CLIENT NUMBER: %s" % [str(average_client_number)])
	print("AVG. TIME FOR CLIENT: %s" % [str(average_time_for_client)])
	print("FINAL ORDER LIST NUMBER: %s" % [str(order_lists.size())])
	print("FINAL ORDER LISTS:")
	var prices = $LevelConfig.prices
	for _orders in order_lists:
		var references = []
		var total = 0.0
		for _order in _orders:
			total += prices[_order.reference]
			references.append(
				"%s = %s" % [
					_order.reference, str(prices[_order.reference])
				]
			)
		print("Total: %s, References: %s" % [str(total), str(references)])
	print("FINAL TIMEOUTS:")
	print(timeout_seconds)
	print("TOTAL: %s" % [timeout_seconds.size()])


func select_random_dishes():
	var n_orders = rng.randi_range(1, max_orders)
	var order = []
	for _unused in range(n_orders):
		var cat = _get_random_category()
		var dish_ref = _get_random_dish_from_category(cat)
		order.append(dish_ref)

	var final_order = []
	for dish_ref in _sort_dishes_by_category(order):
		final_order.append(menu.get_dish(dish_ref).duplicate())

	return final_order


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
		idx, current_time, dishes, $LevelConfig.max_arrival_time,
		$LevelConfig.patience, $LevelConfig.seconds_gained_on_delivery, rng
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
