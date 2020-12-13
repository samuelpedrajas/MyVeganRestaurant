extends Node2D


export(String) var reference = ""
export(int) var order = 0
export(int) var cook_time = -1
export(int) var burn_time = -1
export(bool) var hide_ingredient = false
export(Array) var acceptable_ingredients = []

var current_time = 0
var ingredient = null
var platform = null


func _ready():
	self.platform = get_node_or_null("Platform")


func is_accepted(_ingredient):
	return self.ingredient == null \
		and _ingredient.reference in self.acceptable_ingredients


func add_ingredient(_ingredient):
	if not is_accepted(_ingredient):
		print("ERROR: ingredient not accepted!!!")
		return
	self.ingredient = _ingredient
	$Placeholder.add_child(_ingredient)
