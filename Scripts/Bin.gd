extends Node2D

var throw_time1 = 0.4
var throw_scale1 = Vector2(0.75, 0.75)
var throw_scale2 = Vector2(0.5, 0.5)


func throw_item(item, origin):
	var tween = Tween.new()
	tween.connect(
		"tween_all_completed", self, "_tween_completed1",
		[item, tween]
	)
	tween.interpolate_method(
		item, "set_global_position", origin.get_throw_position(),
		to_global($Origin.get_position()), throw_time1,
		Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	tween.interpolate_method(
		item, "set_scale", item.get_scale(), throw_scale1,
		throw_time1, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	add_child(tween)
	add_child(item)
	tween.start()


func _tween_completed1(item, tween):
	var throw_time2 = $AnimationPlayer.get_animation("throw").length
	$AnimationPlayer.play("throw")
	tween.disconnect(
		"tween_all_completed", self, "_tween_completed1"
	)
	tween.connect(
		"tween_all_completed", self, "_tween_completed2",
		[item, tween]
	)
	tween.interpolate_method(
		item, "set_position", $Origin.get_position(),
		$Destination.get_position(), throw_time2
	)
	tween.interpolate_property(
		item, "modulate", item.modulate,
		item.modulate * Color(1.0, 1.0, 1.0, 0.0), throw_time2
	)
	tween.interpolate_method(
		item, "set_scale", item.get_scale(), throw_scale2,
		throw_time2, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	tween.start()


func _tween_completed2(item, tween):
	remove_child(tween)
	tween.queue_free()
	item.queue_free()
