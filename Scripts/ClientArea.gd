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
var base_variability = 1.0
var added_variability = 2.0
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
	for i in range(0, average_client_number):
		if orders[i] == []:
			continue
		orders[i] = Utils.sort_by_attribute(orders[i], "order", "asc")
		order_lists.append([])
		for _order in orders[i]:
			order_lists[-1].append(_order["dish"])

	print("CALCULATED GOAL: %s" % [str(calculated_goal)])
	print("GUARANTEED COINS: %s" % [str(guaranteed_coins)])
	print("CALCULATED AVERAGE CLIENT NUMBER: %s" % [str(average_client_number)])
	print("FINAL ORDER LIST NUMBER: %s" % [str(order_lists.size())])
	print("FINAL ORDER LISTS:")
	for _orders in order_lists:
		var references = []
		for _order in _orders:
			references.append(_order.reference)
		print(references)


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
