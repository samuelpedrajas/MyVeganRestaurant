extends Node


var coins = 0
var kitchen_upgrades = {
	"FastFood": {
		"Machines": {
			"Grill": [
				{
					"CookingTime": 7,
					"Slots": 1
				},
				{
					"CookingTime": 5,
					"Slots": 2
				},
				{
					"CookingTime": 3,
					"Slots": 4
				}
			],
			"Fryer": [
				{
					"CookingTime": 7,
					"Slots": 1
				},
				{
					"CookingTime": 5,
					"Slots": 2
				},
				{
					"CookingTime": 3,
					"Slots": 3
				}
			],
			"ColaPump": [
				{
					"CookingTime": 7,
					"Platforms": 1
				},
				{
					"CookingTime": 5,
					"Platforms": 2
				},
				{
					"CookingTime": 3,
					"Platforms": 3
				}
			]
		},
		"Plate": [
			{
				"Slots": 1
			},
			{
				"Slots": 2
			},
			{
				"Slots": 4
			},
		]
	}
}


func get_kitchen_upgrades(kitchen_name):
	return kitchen_upgrades[kitchen_name]
