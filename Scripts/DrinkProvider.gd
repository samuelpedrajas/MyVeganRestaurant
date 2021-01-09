extends Node2D


export(NodePath) onready var delivery = get_node(delivery)
export(Array, NodePath) var platforms = []

var upgrade = 0


func get_throw_position():
	return $Placeholder.get_global_position()


func set_config(machine_level, machine_upgrades):
	self.upgrade = machine_level
	var n_platforms = machine_upgrades["Platforms"]
	for i in range(platforms.size()):
		platforms[i] = get_node(platforms[i])
		if n_platforms <= i:
			platforms[i].hide()
		else:
			platforms[i].show()
	_on_Timer_food_cooked()
	print("DrinkProvider upgraded")


func _on_Timer_food_cooked():
	$AnimationPlayer.play("prepared_animation")
	$Timer.hide()
	for platform in platforms:
		if platform.is_visible() and platform.delivery == null:
			var new_delivery = delivery.duplicate()
			new_delivery.connect("delivered", self, "_on_Drink_delivered")
			platform.add_delivery(new_delivery)


func _on_Drink_delivered(_delivery):
	$Timer.stop()
	$Timer.start()
	$Timer.show()
	$AnimationPlayer.play("preparing_animation")
