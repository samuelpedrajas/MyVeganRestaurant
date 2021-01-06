extends Node2D


export(NodePath) onready var kitchen = get_node(kitchen)
export(bool) var autohide_timer = true
export(Array, NodePath) var platforms = []


func _ready():
	for i in range(platforms.size()):
		platforms[i] = get_node(platforms[i])
	_on_Timer_food_cooked()


func get_throw_position():
	return $Placeholder.get_global_position()


func _on_Timer_food_cooked():
	$AnimationPlayer.play("prepared_animation")
	if autohide_timer:
		$Timer.hide()
	for platform in platforms:
		if platform.dish == null:
			var dish = $Placeholder/Cola.duplicate()
			dish.connect("delivered", self, "_on_Drink_delivered")
			platform.add_dish(dish)


func _on_Drink_delivered(_dish):
	$Timer.stop()
	$Timer.start()
	$Timer.show()
	$AnimationPlayer.play("preparing_animation")
