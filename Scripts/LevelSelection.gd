extends Control


signal game_request
signal open_request
signal close_request

var level_list = []
var level_button_text = "Level %s"


var kitchen_levels = {
	"FastFood": load("res://Scenes/FastFood/FastFoodLevels.tscn")
}


func open_screen(kitchen_name):
	var levels = kitchen_levels[kitchen_name].instance()
	level_list = levels.get_levels()
	for i in range(level_list.size()):
		var new_button = $ButtonTemplate/Button.duplicate()
		new_button.set_level(i)
		new_button.set_text(level_button_text % [str(i + 1)])
		new_button.connect("level_selected", self, "_on_level_selected")
		$ScrollContainer/Levels.add_child(new_button)
	show()


func close_screen():
	hide()
	level_list = []
	var buttons = $ScrollContainer/Levels
	for button in buttons.get_children():
		buttons.remove_child(button)
		button.disconnect("level_selected", self, "_on_level_selected")
		button.queue_free()


func _on_level_selected(i):
	emit_signal("game_request", level_list[i])


func _on_Upgrade_pressed():
	emit_signal("open_request", "KitchenUpgrades")


func _on_Back_pressed():
	emit_signal("close_request")
