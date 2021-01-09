extends Node2D


var upgrade = 0
export(String) var reference
export(bool) var throwable = true


func get_level_reference():
	return get_child(self.level).reference


func set_cooked():
	_play_cooked_animation()


func set_burned():
	_play_burned_animation()


func set_config(machine_level):
	self.upgrade = machine_level
	_play_default_animation()
	print("Ingredient upgraded")


func _play_default_animation():
	if get_node_or_null("AnimationPlayer") == null:
		return
	var anim_name = "default_animation_%s" % [str(self.upgrade)]
	$AnimationPlayer.play(anim_name)


func _play_cooked_animation():
	if get_node_or_null("AnimationPlayer") == null:
		return
	var anim_name = "cooked_animation_%s" % [str(self.upgrade)]
	$AnimationPlayer.play(anim_name)


func _play_burned_animation():
	if get_node_or_null("AnimationPlayer") == null:
		return
	var anim_name = "burned_animation_%s" % [str(self.upgrade)]
	$AnimationPlayer.play(anim_name)
