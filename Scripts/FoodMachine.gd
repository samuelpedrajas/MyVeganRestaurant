extends Node2D


export(String) var reference = ""
export(int) var order = 0
export(int) var cook_time = -1
export(int) var burn_time = -1
export(bool) var hide_ingredient = false
export(NodePath) onready var kitchen = get_node(kitchen)


var current_time = 0
var ingredient = null
var platform = null


func _ready():
	self.platform = get_node_or_null("Platform")


func is_busy():
	return self.ingredient != null


func add_item(_ingredient):
	if is_busy():
		print("ERROR: machine is busy!!!")
		return
	self.ingredient = _ingredient
	$Placeholder.add_child(_ingredient)
	$Timer.resume_or_start()


func drop_item():
	$Placeholder.remove_child(self.ingredient)
	self.ingredient = null
	$Timer.stop()


func _on_Timer_food_cooked():
	self.ingredient.evolve()


func _on_Timer_food_burned():
	self.ingredient.evolve()


func _on_ClickableArea_clicked():
	if self.ingredient != null:
		kitchen.use_item(self.ingredient, self)
