extends Node2D


export var cooking_time = 8
export var burning_time = 8

var resolution = 0.1
var _count = 0

signal food_cooked
signal food_burned

var food_is_cooked = false

enum states {
	STOPPED,
	PAUSED,
	WORKING
}
var status = states.STOPPED

func _ready():
	#start()
	pass

func countdown():
	_count = 0
	$Timer.start()

func start():
	status = states.WORKING
	food_is_cooked = false
	$Timer.set_paused(false)
	$Timer.set_wait_time(self.resolution)
	$CookingProgress.show()
	countdown()

func stop():
	status = states.STOPPED
	$Timer.stop()
	$CookingProgress.hide()
	$BurningProgress.hide()
	$CookingProgress.set_value(0)
	$BurningProgress.set_value(0)

func pause():
	status = states.PAUSED
	$Timer.set_paused(true)

func resume():
	status = states.WORKING
	$Timer.set_paused(false)

func resume_or_start():
	if status == states.STOPPED:
		start()
	elif status == states.PAUSED:
		resume()
	else:
		# should never enter here
		print("WARNING: ", status)

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
		$BurningProgress.show()
		_count = 0
	elif limit_surpassed and food_is_cooked:
		print("Food burned!")
		emit_signal("food_burned")
		pause()
