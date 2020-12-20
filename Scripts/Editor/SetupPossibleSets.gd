tool
extends EditorScript


var burger = [
	{
		"dish_name": "BurgerBread", 
		"ingredients": ["BurgerBread"],
		"profit": 0
	},
	{
		"dish_name": "SimpleBurger", 
		"ingredients": ["BurgerBread", "CookedBurger"],
		"profit": 0
	},
	{
		"dish_name": "LettuceBurger", 
		"ingredients":["BurgerBread", "CookedBurger", "Lettuce"],
		"profit": 0
	},
	{
		"dish_name": "TomatoBurger", 
		"ingredients": ["BurgerBread", "CookedBurger", "Tomato"],
		"profit": 0
	},
	{
		"dish_name": "CompleteBurger", 
		"ingredients": ["BurgerBread", "CookedBurger", "Lettuce", "Tomato"],
		"profit": 0
	}
]

var possible_sets = burger

func _run():
	var root = get_scene()
	root.possible_sets = self.possible_sets.duplicate(true)
