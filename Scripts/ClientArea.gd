extends Control


export(int) var max_n_clients = 5
export(NodePath) onready var menu = get_node(menu)

var client_scene = preload("res://Scenes/Client.tscn")

var rng = RandomNumberGenerator.new()
var pending_clients = 0
var position_availability = []


func start():
	rng.randomize()
	for _i in range(max_n_clients):
		position_availability.append(true)
	for _i in range(max_n_clients):
		new_client()


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
