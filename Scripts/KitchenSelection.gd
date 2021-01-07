extends Control


signal kitchen_selected


func open_screen():
	show()


func close_screen():
	hide()


func _on_FastFood_pressed():
	emit_signal("kitchen_selected", "FastFood")
