extends Control
var _timer 
const _delta = 0.8
const _delta2 = 0.3
var cat_visible = true

func _ready():
	_timer = Timer.new()
	_timer.set_physics_process(true)
	_timer.set_wait_time(_delta2)
	_timer.timeout.connect(self.on_timer_timeout)
	add_child(_timer)
	_timer.stop()

func hide_cursor():
	_timer.stop()
	$TextureRect.set_visible(false)
	
func show_cursor():
	_timer.start()
	$TextureRect.set_visible(true)
	
func on_timer_timeout():
	if cat_visible:
		_timer.set_wait_time(_delta)
	else:
		_timer.set_wait_time(_delta2)
	cat_visible = not cat_visible
	$TextureRect.set_visible(cat_visible)
