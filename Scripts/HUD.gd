extends Control


signal start_game

func _ready():
	get_tree().get_root().connect("size_changed", self, "_on_size_changed")


### Signal Handlers ###

func _on_PlayButton_pressed():
	emit_signal("start_game")
	$StartingLayer.hide()

func _on_size_changed():
	var screen_size = OS.get_screen_size()
	var viewport_size = get_viewport_rect().size
	var position_offset = -(viewport_size - screen_size) / 2.0
	print("Resizing HUD")
	set_size(viewport_size)
	set_position(position_offset)
