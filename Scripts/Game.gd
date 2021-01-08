extends Control


var kitchen_scenes = {
	"FastFood": "res://Scenes/FastFood/FastFood.tscn"
}

onready var kitchen_upgrades_status = $Status
onready var kitchen_upgrades = $Upgrades
var kitchen = null


func _on_KitchenSelection_kitchen_selected(kitchen_name):
	kitchen = load(kitchen_scenes[kitchen_name]).instance()
	kitchen.hide()
	kitchen.connect("close_request", self, "_on_Kitchen_close_request")
	$KitchenSelection.close_screen()
	$LevelSelection.open_screen(kitchen_name)


func _on_LevelSelection_close_request():
	$LevelSelection.close_screen()
	$KitchenSelection.open_screen()


func _on_LevelSelection_open_upgrades_request():
	var kitchen_name = kitchen.get_name()
	$KitchenUpgrades.open_screen(
		kitchen,
		kitchen_upgrades.get_kitchen_upgrades(kitchen_name),
		kitchen_upgrades_status.get_kitchen_upgrade_status(kitchen_name)
	)


func _on_KitchenUpgrades_close_request():
	$KitchenUpgrades.close_screen()


func _on_LevelSelection_game_request(level):
	add_child(kitchen)
	var kitchen_name = kitchen.get_name()
	kitchen.call_deferred(
		"open_screen",
		level,
		kitchen_upgrades.get_kitchen_upgrades(kitchen_name),
		kitchen_upgrades_status.get_kitchen_upgrade_status(kitchen_name)
	)


func _on_Kitchen_close_request():
	kitchen.hide()
	remove_child(kitchen)
	kitchen.disconnect("close_request", self, "_on_Kitchen_close_request")
	kitchen.queue_free()
	kitchen = null
	get_tree().get_root().set_disable_input(false)
