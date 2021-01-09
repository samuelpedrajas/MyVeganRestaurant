extends Node


var coins = 0
var kitchen_status = {
	"FastFood": {
		"Deliverables": {
			"Cola": 0,
			"CompleteBurger": 0,
			"Fries": 0
		},
		"Instruments": {
			"Grill": 0,
			"Fryer": 0,
			"ColaPump": 0,
			"Plate": 0
		}
	}
}


func get_kitchen_status(kitchen_name):
	return kitchen_status[kitchen_name]
