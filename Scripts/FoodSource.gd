extends Node2D


var ingredient = null
export(NodePath) onready var kitchen = get_node(kitchen)


func _ready():
	self.ingredient = $Ingredient
	if self.ingredient == null:
		print("ERROR: Ingredient not configured for this FoodSource")
	if self.kitchen == null:
		print("ERROR: Kitchen not configured for this FoodSource")


func drop_item():
	pass


func _on_ClickableArea_clicked():
	self.kitchen.use_item(self.ingredient.duplicate(), self)
