extends Node2D


export(Array, NodePath) var platforms = []


func _ready():
	for i in range(platforms.size()):
		platforms[i] = get_node(platforms[i])
	_on_Timer_food_cooked()


func get_throw_position():
	return $Placeholder.get_global_position()


func _on_Timer_food_cooked():
	$AnimationPlayer.play("prepared_animation")
	$Timer.hide()
	for platform in platforms:
		if platform.delivery == null:
			var delivery = $Placeholder/Cola.duplicate()
			delivery.connect("delivered", self, "_on_Drink_delivered")
			platform.add_delivery(delivery)


func _on_Drink_delivered(_delivery):
	$Timer.stop()
	$Timer.start()
	$Timer.show()
	$AnimationPlayer.play("preparing_animation")