extends Control

var firstTimes
var current_ft
var secondTimes
var current_st
# Called when the node enters the scene tree for the first time.
func _ready():
	firstTimes = [$CenterContainer/VBoxContainer/FirstTime/N1,
			$CenterContainer/VBoxContainer/FirstTime/N2,
			$CenterContainer/VBoxContainer/FirstTime/N3,
			$CenterContainer/VBoxContainer/FirstTime/N4,
			$CenterContainer/VBoxContainer/FirstTime/N5,
			$CenterContainer/VBoxContainer/FirstTime/N6,
			$CenterContainer/VBoxContainer/FirstTime/N7,
			$CenterContainer/VBoxContainer/FirstTime/N8,
			$CenterContainer/VBoxContainer/FirstTime/N9]
	secondTimes = [$CenterContainer/VBoxContainer/SecondTime/N1,
			$CenterContainer/VBoxContainer/SecondTime/N2,
			$CenterContainer/VBoxContainer/SecondTime/N3,
			$CenterContainer/VBoxContainer/SecondTime/N4,
			$CenterContainer/VBoxContainer/SecondTime/N5,
			$CenterContainer/VBoxContainer/SecondTime/N6,
			$CenterContainer/VBoxContainer/SecondTime/N7,
			$CenterContainer/VBoxContainer/SecondTime/N8,
			$CenterContainer/VBoxContainer/SecondTime/N9]
	current_ft = 3
	current_st = 3
	
func setup(time_f, time_s):
	firstTimes[current_ft].set_visible(false)
	secondTimes[current_st].set_visible(false)
	current_ft = time_f -1
	current_st = time_s -1
	firstTimes[current_ft].set_visible(true)
	secondTimes[current_st].set_visible(true)

