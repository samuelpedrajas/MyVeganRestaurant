extends Node2D


export(String) var reference
export(Array) var next_stages = []

var level = 0


func evolve():
	get_node(self.reference).hide()
	self.level += 1
	self.reference = self.next_stages[self.level]
	get_node(self.reference).show()
