extends Node2D


export(NodePath) onready var kitchen = get_node(kitchen)
export(bool) var autohide_timer = true

var dish = null


func _ready():
	_on_Timer_food_cooked()


func drop_item():
	self.dish = null
	$Timer.stop()
	$Timer.resume_or_start()
	$Timer.show()
	$AnimationPlayer.play("preparing_animation")


func get_throw_position():
	return $Placeholder.get_global_position()


func _on_Timer_food_cooked():
	self.dish = $Placeholder/Cola.duplicate()
	$AnimationPlayer.play("prepared_animation")
	if autohide_timer:
		$Timer.hide()


func _on_ClickableArea_clicked():
	if self.dish != null:
		kitchen.deliver(self.dish, self)
