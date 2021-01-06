extends Node2D


export(NodePath) onready var kitchen = get_node(kitchen)
export(bool) var is_platform = false
export(Vector2) var placeholder_position

var delivery = null
var double_click_threshold = 0.5
var double_click = false


func _ready():
	if placeholder_position != null:
		$Placeholder.set_position(placeholder_position)


func add_ingredient(ingredient):
	var new_delivery = kitchen.menu.get_new_delivery(delivery, ingredient)
	add_delivery(new_delivery)


func add_delivery(_delivery):
	for child in $Placeholder.get_children():
		child.queue_free()
	var old_delivery_name = "None"
	if  self.delivery != null:
		old_delivery_name = self.delivery.reference
	self.delivery = _delivery
	$Placeholder.add_child(_delivery)
	print("Plate: %s ---> %s" % [old_delivery_name, _delivery.reference])


func get_throw_position():
	return $Placeholder.get_global_position()


func drop_item():
	$Placeholder.remove_child(self.delivery)
	self.delivery = null


func _on_ClickableArea_pressed():
	deliver()


func deliver():
	if delivery == null:
		pass
	elif double_click:
		kitchen.throw_to_bin(delivery, self)
		double_click = false
	elif is_platform:
		kitchen.deliver(delivery, self)
	else:
		var useless = kitchen.is_useless(delivery)
		if useless and delivery.throwable:
			double_click = true
			$DoubleClick.start()
		else:
			kitchen.deliver(delivery, self)


func _on_DoubleClick_timeout():
	double_click = false


func _on_DoubleClick_ready():
	$DoubleClick.set_wait_time(double_click_threshold)
