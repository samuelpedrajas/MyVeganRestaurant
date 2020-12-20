extends Node2D


var level = 0


func get_reference():
	return get_child(self.level).reference


func evolve():
	get_child(self.level).hide()
	self.level += 1
	get_child(self.level).show()


func get_destination():
	return get_child(self.level).destination
