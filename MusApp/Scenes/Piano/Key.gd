extends ColorRect

var parent
# Called when the node enters the scene tree for the first time.
func _ready():
	parent = get_parent()
	

func _gui_input(event):
	if event.is_action_pressed("click"):
		parent.activate()
	elif event.is_action_released("click"):
		parent.deactivate()
