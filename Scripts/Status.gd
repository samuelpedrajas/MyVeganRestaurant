extends Node


var kitchen_upgrades = {
	"FastFood": {
		"Machines": {
			"Grill": 0,
			"Fryer": 0,
			"ColaPump": 0
		},
		"Deliveries": {
			"BurgerBread": 0,
			"Cola": 0,
			"CompleteBurger": 0,
			"Fries": 0,
			"LettuceBurger": 0,
			"TomatoBurger": 0,
			"SimpleBurger": 0
		},
		"IngredientSources": {
			"BreadSource": 0,
			"FriesSource": 0,
			"BurgerSource": 0,
			"LettuceSource": 0,
			"TomatoSource": 0
		},
		"Plate": 0
	}
}


func get_kitchen_upgrade_status(kitchen_name):
	return kitchen_upgrades[kitchen_name]
