extends Node2D


export(NodePath) onready var kitchen = get_node(kitchen)

var dish = null
var preparing = false


func drop_item():
	self.dish = null
	$AnimationPlayer.play("default_animation")
	$Timer.stop()


func _on_Timer_food_cooked():
	self.dish = $Placeholder/Cola.duplicate()
	$AnimationPlayer.play("prepared_animation")
	preparing = false


func _on_ClickableArea_clicked():
	if self.dish != null:
		kitchen.deliver(self.dish, self)
	elif not preparing:
		preparing = true
		$Timer.resume_or_start()
		$AnimationPlayer.play("preparing_animation")
