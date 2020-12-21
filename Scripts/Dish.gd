extends Node


export(String) var reference
export(int) var profit
export(int) var discard_price
export(Array) var ingredients
export(bool) var deliverable
export(Vector2) var v_limits


func _ready():
	add_child(Button.new())


func get_height():
	return abs(v_limits[0]) + abs(v_limits[1])


func get_y_offset():
	return abs(v_limits[0]) - abs(v_limits[1])
