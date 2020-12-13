extends Node2D


func _ready():
	get_tree().set_pause(true)
	get_tree().get_root().connect("size_changed", self, "_on_size_changed")


func select_food_machine(ingredient):
	var machines = get_tree().get_nodes_in_group("FoodMachine")
	machines = Utils.sort_by_attribute(machines, "order")
	for machine in machines:
		if machine.is_accepted(ingredient):
			return machine
	return null

func use_ingredient(ingredient):
	print("Using ingredient: %s" % [ingredient.reference])
	var machine = select_food_machine(ingredient)
	if machine == null:
		print("No machine is available")
		return
	ingredient.get_parent().remove_child(ingredient)
	machine.add_ingredient(ingredient)
	print("%s was added to %s" % [ingredient.reference, machine.reference])

### Signal Handlers ###

func _on_HUD_start_game():
	yield(get_tree(), "idle_frame")
	get_tree().set_pause(false)


func _on_size_changed():
	var screen_size = OS.get_screen_size()
	var viewport_size = get_viewport_rect().size
	var position_offset = (viewport_size - screen_size) / 2.0
	print("Resizing Kitchen")
	set_position(position_offset)
	$Table.set_global_position(
		Vector2(
			$Table.get_global_position().x,
			viewport_size.y - $Table.texture.get_size().y / 2.0
		)
	)
