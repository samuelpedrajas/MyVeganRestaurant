extends Node2D


export(String) var reference = ""
export(bool) var hide_ingredient = false
export(NodePath) onready var kitchen = get_node(kitchen)
export(NodePath) var platform
export(bool) var serve_automatically = false

var ingredient = null


func _ready():
	self.platform = get_node_or_null(platform)
	$AnimationPlayer.play("default_animation")


func is_busy():
	var platform_is_full = false
	if self.platform != null:
		platform_is_full = self.platform.dish != null
	return self.ingredient != null or platform_is_full


func add_item(_ingredient):
	if is_busy():
		print("ERROR: machine is busy!!!")
		return
	_ingredient.evolve()
	self.ingredient = _ingredient
	if not self.hide_ingredient:
		$Placeholder.add_child(_ingredient)
	$AnimationPlayer.play("preparing_animation")
	$Timer.start()


func drop_item():
	if not hide_ingredient:
		$Placeholder.remove_child(self.ingredient)
	self.ingredient = null
	$AnimationPlayer.play("default_animation")
	$Timer.stop()


func get_throw_position():
	return $Placeholder.get_global_position()


func _on_Timer_food_cooked():
	self.ingredient.evolve()
	if self.serve_automatically:
		kitchen.use_item(self.ingredient, self)


func _on_Timer_food_burned():
	self.ingredient.evolve()


func _on_ClickableArea_pressed():
	if self.ingredient != null:
		kitchen.use_item(self.ingredient, self)
	elif self.platform != null and platform.dish != null:
		kitchen.deliver(platform.dish, platform)
