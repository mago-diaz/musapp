extends Control

var Position_B = ["B5", "B3", "B1"]
var Position_T = ["T2", "T4", "T6"]
# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent()
	var line1 = get_node("L1")
	var line2 = get_node("L2")
	var line3 = get_node("L3")
	var line4 = get_node("L4")
	var line5 = get_node("L5")
	if parent:
		var parent_name = str(parent.get_name())
		var parent_num = parent_name[1].to_int()
		if parent_name < "M1":
			if parent_num % 2 == 0:
				if parent_name <= "B4":
					line2.set_visible(true)
				if parent_name <= "B2":
					line4.set_visible(true)
			else:
				if parent_name <= "B5":
					line1.set_visible(true)
				if parent_name <= "B3":
					line3.set_visible(true)
				if parent_name <= "B1":
					line5.set_visible(true)
		if parent_name > "M9":
			if parent_num % 2 == 0:
				if parent_name >= "T4":
					line3.set_visible(true)
				if parent_name >= "T2":
					line1.set_visible(true)
				if parent_name >= "T6":
					line5.set_visible(true)
			else:
				if parent_name > "T1":
					line2.set_visible(true)
				if parent_name >= "T3":
					line4.set_visible(true)


func setup(accidental = ""):
	if accidental == "#":
		$Flat.set_visible(false)
		$Sharp.set_visible(true)
		$Natural.set_visible(false)
	elif accidental == "b":
		$Flat.set_visible(true)
		$Sharp.set_visible(false)
		$Natural.set_visible(false)
	elif accidental == "c":
		$Flat.set_visible(false)
		$Sharp.set_visible(false)
		$Natural.set_visible(true)
	else:
		$Flat.set_visible(false)
		$Sharp.set_visible(false)
		$Natural.set_visible(false)
