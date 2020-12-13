extends Node2D


func _ready():
	get_tree().set_pause(true)
	get_tree().get_root().connect("size_changed", self, "_on_size_changed")


func use_ingredient(ingredient):
	print("Using ingredient: %s" % [ingredient.name])

### Signal Handlers ###

func _on_HUD_start_game():
	yield(get_tree(), "idle_frame")
	get_tree().set_pause(false)


func _on_size_changed():
	var screen_size = OS.get_screen_size()
	var viewport_size = get_viewport_rect().size
	var position_offset = (viewport_size - screen_size) / 2.0
	print("Resizing Kitchen")
	set_position(position_offset)
	$Table.set_global_position(
		Vector2(
			$Table.get_global_position().x,
			viewport_size.y - $Table.texture.get_size().y / 2.0
		)
	)
