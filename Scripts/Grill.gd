extends Node2D


export(NodePath) onready var kitchen = get_node(kitchen)

var upgrade = 0
var ingredient = null
var burned = false


func _ready():
	$AnimationPlayer.play("default_animation")


func is_busy():
	return self.ingredient != null


func add_item(_ingredient):
	if is_busy():
		print("ERROR: machine is busy!!!")
		return
	self.ingredient = _ingredient
	$Placeholder.add_child(_ingredient)
	$AnimationPlayer.play("preparing_animation")
	$Timer.start()


func drop_item():
	self.burned = false
	self.ingredient = null
	$AnimationPlayer.play("default_animation")
	$Timer.stop()


func send_to_plate():
	var plate = kitchen.select_plate(self.ingredient)
	if plate != null:
		$Placeholder.remove_child(self.ingredient)
		plate.add_ingredient(self.ingredient)
		drop_item()
	else:
		print("No plates available for %s" % [get_name()])


func send_to_bin():
	$Placeholder.remove_child(self.ingredient)
	kitchen.throw_to_bin(self.ingredient, self)


func get_throw_position():
	return $Placeholder.get_global_position()


func set_config(machine_level, machine_upgrades):
	self.upgrade = machine_level
	print("Grill upgraded")


func _on_Timer_food_cooked():
	self.ingredient.evolve()


func _on_Timer_food_burned():
	self.ingredient.evolve()
	self.burned = true
	print("%s burned!" % [get_name()])


func _on_ClickableArea_pressed():
	if self.ingredient != null:
		if burned:
			send_to_bin()
		else:
			send_to_plate()
