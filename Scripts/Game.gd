extends Control


onready var current_screen = $KitchenSelection


func _on_KitchenSelection_kitchen_selected(kitchen_name):
	$KitchenSelection.close_screen()
	$LevelSelection.open_screen(kitchen_name)


func _on_LevelSelection_close_request():
	$LevelSelection.close_screen()
	$KitchenSelection.open_screen()


func _on_LevelSelection_open_request(screen_name):
	get_node(screen_name).open_screen()


func _on_KitchenUpgrades_close_request():
	$KitchenUpgrades.close_screen()
