extends Node


export(float) var max_time = 60
export(float) var max_arrival_time = 3.0
export(float) var average_time_for_client = 3.0
export(float) var average_reward_for_client = 220.0

export(float) var seconds_gained_on_delivery = average_time_for_client / 3.0
export(float) var patience = 10.0 * average_time_for_client
export(float) var base_variability = 0.5
export(float) var added_variability = 1.5
export(float) var added_variability_percentage = 0.4 #  0.4
export(Array) var maximums = [0.0, 1.0]  # [0.8]

export(Dictionary) var prices = {
	"Fries": 50,
	"SimpleBurger": 75,
	"TomatoBurger": 100,
	"LettuceBurger": 100,
	"CompleteBurger": 125,
	"Cola": 25
}
export(Dictionary) var discard_prices = {
	"TomatoBurger": 75,
	"LettuceBurger": 75,
	"CompleteBurger": 100,
	"BurgerIngredient": 50
}

export(Dictionary) var category_order = {
	"Complement": 0,
	"Main": 1,
	"Drink": 2
}

export(Dictionary) var category_probability = {
	"Complement": 30,
	"Main": 40,
	"Drink": 30
}
export(Dictionary) var delivery_probability = {
	"Complement": {
		"Fries": 100
	},
	"Main": {
		"SimpleBurger": 25,
		"TomatoBurger": 25,
		"LettuceBurger": 25,
		"CompleteBurger": 25
	},
	"Drink": {
		"Cola": 100
	}
}
