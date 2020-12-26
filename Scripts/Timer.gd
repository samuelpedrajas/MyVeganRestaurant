extends Node2D


export var cooking_time = 8
export var burning_time = 8

var resolution = 0.1
var _count = 0

signal food_cooked
signal food_burned

var food_is_cooked = false


func countdown():
	_count = 0
	$Timer.start()


func start():
	food_is_cooked = false
	$Timer.set_paused(false)
	$Timer.set_wait_time(self.resolution)
	$CookingProgress.show()
	countdown()


func stop():
	$Timer.stop()
	$CookingProgress.hide()
	$BurningProgress.hide()
	$CookingProgress.set_value(0)
	$BurningProgress.set_value(0)


func pause():
	$Timer.set_paused(true)


func resume():
	$Timer.set_paused(false)


func _on_Timer_timeout():
	_count += 1
	var ellapsed = resolution * _count

	var limit
	if self.food_is_cooked:
		limit = burning_time
		$BurningProgress.set_value(ellapsed / limit * 100)
	else:
		limit = cooking_time
		$CookingProgress.set_value(ellapsed / limit * 100)

	var limit_surpassed = ellapsed >= limit
	if limit_surpassed and not food_is_cooked:
		food_is_cooked = true
		print("Food cooked!")
		emit_signal("food_cooked")
		if burning_time < 0:
			pause()
		else:
			$BurningProgress.show()
		_count = 0
	elif limit_surpassed and food_is_cooked:
		print("Food burned!")
		emit_signal("food_burned")
		pause()
