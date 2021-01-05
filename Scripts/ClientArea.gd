extends Control


export(int) var max_n_clients = 4
export(NodePath) onready var menu = get_node(menu)

var client_scene = preload("res://Scenes/Client.tscn")

var rng = RandomNumberGenerator.new()
var num_clients = 0
var current_time = 0
var position_availability = []
var current_n_clients = 0


export(float) var max_time = 60
export(float) var max_arrival_time = 3.0
export(float) var average_time_for_client = 4.0
export(float) var average_reward_for_client = 120.0
export(Array) var category_probabilities = [0.2, 0.6, 0.2]
export(int) var max_orders = 4

export(float) var seconds_gained_on_delivery = 3.0 * average_time_for_client
export(float) var patience = 10.0 * average_time_for_client
export(float) var base_variability = 0.0
export(float) var added_variability = 0.0
export(float) var added_variability_percentage = 0.0 #  0.4
export(Array) var maximums = [0.0, 1.0]  # [0.8]

export(Dictionary) var prices = {
	"Fries": 50,
	"SimpleBurger": 75,
	"TomatoBurger": 100,
	"LettuceBurger": 100,
	"CompleteBurger": 125,
	"Cola": 25
}
export(Dictionary) var discard_prices = {
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


func _build_order_lists():
	var orders = Utils.initialise_array(average_client_number, [])
	var categories = menu.get_children()
	var n_categories = menu.get_child_count()

	guaranteed_coins = 0
	var cat_idx = 0
	var cat_probability = category_probabilities[cat_idx]
	for i in range(0, average_client_number):
		var progress = float(i) / average_client_number
		if cat_probability <= progress:
			cat_idx += 1
			if n_categories - 1 <= cat_idx:
				cat_probability = 1.0
			else:
				cat_probability += category_probabilities[cat_idx]
		# get deliverable dishes
		var dishes = []
		for dish in categories[cat_idx].get_children():
			if dish.deliverable:
				dishes.append(dish)
		var n_dishes = dishes.size()
		var selected = rng.randi_range(0, n_dishes - 1)
		var dish_obj = {
			"dish": dishes[selected].duplicate(),
			"order": cat_idx
		}
		orders[i].append(dish_obj)
		guaranteed_coins += prices[dish_obj["dish"].reference]

	# dish distribution
	while guaranteed_coins < calculated_goal:
		for i in range(0, average_client_number):
			if orders[i].size() >= max_orders:
				continue
			cat_idx = 0
			cat_probability = category_probabilities[cat_idx]
			for j in range(0, n_categories):
				var p = rng.randf()
				if p <= cat_probability:
					cat_idx = j
					break
				else:
					cat_probability += category_probabilities[j]

			var category = categories[cat_idx]
			# get deliverable dishes
			var dishes = []
			for dish in category.get_children():
				if dish.deliverable:
					dishes.append(dish)
			var n_dishes = dishes.size()
			var selected = rng.randi_range(0, n_dishes - 1)
			var dish_obj = {
				"dish": dishes[selected].duplicate(),
				"order": cat_idx
			}
			orders[i].append(dish_obj)
			var price = prices[dish_obj["dish"].reference]
			guaranteed_coins += price
			if guaranteed_coins == calculated_goal:
				break
			elif guaranteed_coins > calculated_goal:
				orders[i].pop_back()
				guaranteed_coins -= price
				var available_dishes = []
				for dish_reference in prices.keys():
					available_dishes.append({
						"reference": dish_reference,
						"price": prices[dish_reference]
					})
				available_dishes = Utils.sort_by_attribute(
					available_dishes, "price", "asc"
				)
				for dish_info in available_dishes:
					price = dish_info["price"]
					if guaranteed_coins + price >= calculated_goal:
						var dish = menu.get_dish(dish_info["reference"])
						dish_obj = {
							"dish": dish.duplicate(),
							"order": dish.get_parent().get_position_in_parent()
						}
						orders[i].append(dish_obj)
						guaranteed_coins += price
						break
				break

	# sort and assign to order_lists
	for i in range(0, average_client_number):
		if orders[i] == []:
			continue
		orders[i] = Utils.sort_by_attribute(orders[i], "order", "asc")
		order_lists.append([])
		for _order in orders[i]:
			order_lists[-1].append(_order["dish"])
	order_lists.shuffle()


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

	# apply additional variability
	var total = 0
	for i in range(0, num_added_var):
		var substraction = rng.randf_range(base_variability, added_variability)
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
	var max_start = []
	var clients_per_maximum = 0
	if maximums.size() > 0:
		clients_per_maximum = floor(num_added_var / maximums.size())
	if clients_per_maximum > 0:
		for maximum in maximums:
			max_start.append(
				max(min(floor(
					(maximum * timeout_seconds.size()) - (clients_per_maximum / 2.0)
				), usable_time), 1)
			)

	print("MAXIMUM START: %s" % [max_start])
	print("CLIENTS PER MAXIMUM: %s" % [str(clients_per_maximum)])

	# get fastests, slowests and rest
	timeout_seconds.sort()
	var total_fastests = clients_per_maximum * maximums.size()
	var fastests
	var rest
	if total_fastests > 0:
		fastests = timeout_seconds.slice(0, total_fastests - 1)
		rest = timeout_seconds.slice(total_fastests, timeout_seconds.size())
	else:
		fastests = []
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
	rng.randomize()
	self.usable_time = (max_time - average_time_for_client - max_arrival_time)
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
