extends Control


signal close_request

var item_categories = ["Machines", "Deliveries", "IngredientSources"]


func open_screen(kitchen, upgrades, status):
	show()


func close_screen():
	hide()


func _on_Back_pressed():
	emit_signal("close_request")
