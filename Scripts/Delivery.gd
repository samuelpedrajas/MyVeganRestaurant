extends Node2D


signal delivered

export(String) var reference
export(Array) var ingredients
export(Vector2) var v_limits
export(bool) var throwable = true

var client
var client_delivery
var tween = Tween.new()
var served = false


func _ready():
	add_child(tween)


func set_client(_client, _delivery):
	self.client = _client
	self.client_delivery = _delivery


func deliver(from):
	emit_signal("delivered", self)
	var duration = 0.4
	tween.interpolate_method(
		self, "set_global_position", from,
		client_delivery.get_global_position(), duration,
		Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	tween.interpolate_method(
		self, "set_scale", get_scale(), client_delivery.get_parent().get_scale(),
		duration, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	tween.connect("tween_all_completed", self, "die")
	tween.start()


func get_height():
	return abs(v_limits[0]) + abs(v_limits[1])


func get_y_offset():
	return abs(v_limits[0]) - abs(v_limits[1])


func die():
	print("%s died!" % [self.reference])
	client.remove_delivery(client_delivery)
	queue_free()
