extends Node


var coins = 0
var kitchen_status = {
	"FastFood": {
		"Deliverables": {
			"Cola": 2,
			"CompleteBurger": 2,
			"Fries": 2
		},
		"Instruments": {
			"Grill": 2,
			"Fryer": 2,
			"ColaPump": 2,
			"Plate": 2
		}
	}
}


func get_kitchen_status(kitchen_name):
	return kitchen_status[kitchen_name]
