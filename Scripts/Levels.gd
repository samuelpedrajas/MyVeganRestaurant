extends Node


func get_levels():
	return get_children()

func get_level_configuration(i):
	return get_node(str(i))
