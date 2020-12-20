extends Node2D


func throw_item(item):
	$AnimationPlayer.play("throw")
	item.queue_free()
