extends Control


signal open_request
signal close_request

var level_button_text = "Level %s"


var kitchen_levels = {
	"FastFood": load("res://Scenes/FastFood/FastFoodLevels.tscn")
}


func open_screen(kitchen_name):
	var levels = kitchen_levels[kitchen_name].instance()
	var level_list = levels.get_levels()
	for i in range(level_list.size()):
		var new_button = $ButtonTemplate/Button.duplicate()
		new_button.set_text(level_button_text % [str(i + 1)])
		$ScrollContainer/Levels.add_child(new_button)
	show()


func close_screen():
	hide()
	var levels = $ScrollContainer/Levels
	for level in levels.get_children():
		levels.remove_child(level)
		level.queue_free()


func _on_Upgrade_pressed():
	emit_signal("open_request", "KitchenUpgrades")


func _on_Back_pressed():
	emit_signal("close_request")
