extends Control

var timeSignature
var Clefs
var KeySignature
var CurrentKeySignature

# Called when the node enters the scene tree for the first time.
func _ready():
	timeSignature = $HBoxContainer/TimeBox/TimeSignature
	
	Clefs = [$HBoxContainer/ClefBox/GKey, $HBoxContainer/ClefBox/FKey]
	
	KeySignature = [$HBoxContainer/KeyBox/GSignature, $HBoxContainer/KeyBox/FSignature]
	CurrentKeySignature = KeySignature[0]
	

func time_setup(time_f, time_s):
	timeSignature.setup(time_f, time_s)

func clef_setup(index):
	var other_key = int(index + 1) % 2
	Clefs[other_key].set_visible(false)
	Clefs[index].set_visible(true)
	
	KeySignature[other_key].set_visible(false)
	KeySignature[index].set_visible(true)
	CurrentKeySignature = KeySignature[index]

func signature_setup(index):
	CurrentKeySignature.setup(index)
	
func tempo_setup(tempo):
	var tempo_text = $Control2/Label
	tempo_text.text = "= " + str(tempo)
