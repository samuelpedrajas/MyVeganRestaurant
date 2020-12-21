tool
extends EditorScript


func _run():
	var root = get_scene()
	var min_y = 0
	var max_y = 0
	for sprite in root.get_node("Sprites").get_children():
		var h = sprite.texture.get_size().y
		var y = sprite.position.y
		var top = y - h / 2.0
		var bottom = y + h / 2.0

		if top < min_y:
			min_y = top

		if bottom > max_y:
			max_y = bottom
	var v_limits = Vector2(min_y, max_y)
	root.v_limits = v_limits
