extends Control


signal close_request


func open_screen():
	show()


func close_screen():
	hide()


func _on_Back_pressed():
	emit_signal("close_request")
