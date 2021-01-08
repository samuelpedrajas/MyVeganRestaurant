extends Node2D


export(NodePath) onready var platform = get_node(platform)


var ingredient = null
var upgrade = 0


func _ready():
	$AnimationPlayer.play("default_animation")


func is_busy():
	return self.ingredient != null or self.platform.delivery != null


func add_item(_ingredient):
	if is_busy():
		print("ERROR: machine is busy!!!")
		return
	self.ingredient = _ingredient
	$AnimationPlayer.play("preparing_animation")
	$Timer.start()


func send_item():
	platform.add_ingredient(self.ingredient)
	self.ingredient = null
	$AnimationPlayer.play("default_animation")
	$Timer.stop()


func set_upgrade(machine_level, machine_upgrades):
	self.upgrade = machine_level
	print("Fryer upgraded")


func _on_Timer_food_cooked():
	send_item()


func _on_ClickableArea_pressed():
	if platform.delivery != null:
		platform.deliver()
