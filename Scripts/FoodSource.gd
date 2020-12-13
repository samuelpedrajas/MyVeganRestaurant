extends Node2D


var ingredient = null
export(NodePath) var kitchen


func _ready():
	self.ingredient = $Ingredient
	if self.ingredient == null:
		print("ERROR: Ingredient not configured for this FoodSource")
	if self.kitchen == null:
		print("ERROR: Kitchen not configured for this FoodSource")


func _on_ClickableArea_clicked():
	self.kitchen.use_ingredient(self.ingredient)


func _on_ClickableArea_released():
	pass # Replace with function body.
