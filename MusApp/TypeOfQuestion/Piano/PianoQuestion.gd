extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func stop_song():
	$CenterContainer/PianoManager.manually_stop_song()

func stop_all_notes():
	$CenterContainer/PianoManager.stop_all_notes()

func setup(Question):
	$CenterContainer/PianoManager.change_visible(Question['visiblepiano'])

func get_answer():
	return $CenterContainer/PianoManager.get_answer()
