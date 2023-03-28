extends Control

var Ps
# Called when the node enters the scene tree for the first time.
func _ready():
	Ps = [$HBoxContainer/P1,
		$HBoxContainer/P2,
		$HBoxContainer/P3,
		$HBoxContainer/P4,
		$HBoxContainer/P5,
		$HBoxContainer/P6,
		$HBoxContainer/P7]

func setup(index):
	for P in Ps:
		for element in P.get_children():
			element.set_visible(false)
	if index >= 1 and index <= 7:
		var i = 0
		while i < index:
			Ps[i].get_node("num").set_visible(true)
			i += 1
	elif index >= 7:
		var i = 0
		while i < (index - 7):
			Ps[i].get_node("bemol").set_visible(true)
			i += 1
