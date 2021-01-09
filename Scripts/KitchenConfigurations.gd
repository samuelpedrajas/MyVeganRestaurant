extends Node


func get_kitchen_configuration(kitchen_name):
	for kitchen_config_node in get_children():
		if kitchen_name == kitchen_config_node.get_name():
			return kitchen_config_node.kitchen_config
