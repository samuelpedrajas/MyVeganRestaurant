extends Node2D

var throw_time = 0.4
var throw_scale = Vector2(0.5, 0.5)


func throw_item(item, origin):
	var tween = Tween.new()
	var timer = Timer.new()
	tween.connect(
		"tween_all_completed", self, "_tween_completed",
		[item, tween]
	)
	tween.interpolate_method(
		item, "set_global_position", origin.get_throw_position(),
		to_global($Destination.get_position()), throw_time,
		Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	tween.interpolate_method(
		item, "set_scale", item.get_scale(), throw_scale,
		throw_time, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	timer.one_shot = true
	timer.set_wait_time(throw_time - 0.2)
	timer.connect("timeout", self, "_item_arriving", [timer])
	add_child(tween)
	add_child(timer)
	tween.start()
	timer.start()


func _item_arriving(timer):
	$AnimationPlayer.play("throw")
	remove_child(timer)
	timer.queue_free()


func _tween_completed(item, tween):
	remove_child(tween)
	tween.queue_free()
	item.get_parent().remove_child(item)
	item.queue_free()
