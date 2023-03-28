class_name Chronometer
extends Node
var _timer 
var _time
const _delta = 0.01

func _init():
	_time = 0
	_timer = Timer.new()
	_timer.set_physics_process(true)
	_timer.set_wait_time(_delta)
	_timer.timeout.connect(self.on_timer_timeout)
	add_child(_timer)


func on_timer_timeout():
	_time+= _delta

func start():
	_time = 0
	_timer.start()
	
func stop():
	_timer.stop()
	return _time

func get_time():
	return _time

func get_delta():
	return _delta
