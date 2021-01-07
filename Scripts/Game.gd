extends Control


var kitchen_scenes = {
	"FastFood": "res://Scenes/FastFood/FastFood.tscn"
}
var selected_kitchen_name = null
var kitchen = null


func _on_KitchenSelection_kitchen_selected(kitchen_name):
	self.selected_kitchen_name = kitchen_name
	$KitchenSelection.close_screen()
	$LevelSelection.open_screen(kitchen_name)


func _on_LevelSelection_close_request():
	$LevelSelection.close_screen()
	$KitchenSelection.open_screen()


func _on_LevelSelection_open_request(screen_name):
	get_node(screen_name).open_screen()


func _on_KitchenUpgrades_close_request():
	$KitchenUpgrades.close_screen()


func _on_LevelSelection_game_request(level):
	kitchen = load(kitchen_scenes[selected_kitchen_name]).instance()
	kitchen.hide()
	kitchen.connect("close_request", self, "_on_Kitchen_close_request")
	add_child(kitchen)
	kitchen.call_deferred("open_screen", level)


func _on_Kitchen_close_request():
	kitchen.hide()
	remove_child(kitchen)
	kitchen.disconnect("close_request", self, "_on_Kitchen_close_request")
	kitchen.queue_free()
	kitchen = null
	get_tree().get_root().set_disable_input(false)
