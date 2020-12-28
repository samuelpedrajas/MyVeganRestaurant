extends Area2D


signal clicked

var input_disabled = false


func _on_ClickableArea_input_event(_viewport, _event, _shape_idx):
	if _viewport.is_input_handled() or self.input_disabled:
		return
	_viewport.set_input_as_handled()
	if Input.is_action_just_pressed("ui_click"):
		emit_signal("clicked")
		_block_temporary()


func enable():
	self.input_disabled = false
	$Timer.set_paused(false)


func disable():
	self.input_disabled = true
	$Timer.set_paused(true)


func _block_temporary():
	self.input_disabled = true
	$Timer.start()


func _on_Timer_timeout():
	self.input_disabled = false
