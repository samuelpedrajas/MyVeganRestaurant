extends Area2D


signal clicked
signal released

var input_disabled = false


func _on_ClickableArea_input_event(_viewport, _event, _shape_idx):
	if Input.is_action_just_pressed("ui_click") and not self.input_disabled:
		emit_signal("clicked")
	elif Input.is_action_just_released("ui_click"):
		emit_signal("released")


func enable():
	self.input_disabled = false


func disable():
	self.input_disabled = true
