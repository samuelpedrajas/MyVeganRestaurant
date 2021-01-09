extends Node2D


export(NodePath) onready var platform = get_node(platform)


var ingredient = null
var upgrade = 0


func is_busy():
	return self.ingredient != null or self.platform.delivery != null


func add_item(_ingredient):
	if is_busy():
		print("ERROR: machine is busy!!!")
		return
	self.ingredient = _ingredient
	_play_preparing_animation()
	$Timer.start()


func send_item():
	platform.add_ingredient(self.ingredient)
	self.ingredient = null
	_play_default_animation()
	$Timer.stop()


func set_config(machine_level, machine_upgrades):
	self.upgrade = machine_level
	self.platform.show()
	_play_default_animation()
	$Timer.cooking_time = machine_upgrades["CookingTime"]
	print("%s upgraded" % [get_name()])


func _play_default_animation():
	var anim_name = "default_animation_%s" % [str(self.upgrade)]
	$AnimationPlayer.play(anim_name)


func _play_preparing_animation():
	var anim_name = "preparing_animation_%s" % [str(self.upgrade)]
	$AnimationPlayer.play(anim_name)


func _on_Timer_food_cooked():
	send_item()


func _on_ClickableArea_pressed():
	if platform.delivery != null:
		platform.deliver()
