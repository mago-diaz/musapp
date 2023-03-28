extends CenterContainer

var Letter
var IsNew

func _ready():
	pass 


func setup(letter, is_new):
	set_visible(true)
	IsNew = is_new
	Letter = letter
	if not IsNew:
		$VBoxContainer/CenterContainer/HBoxContainer/Label.set_visible(true)
	$VBoxContainer/VBoxContainer/GradeBox/GradeLabel.text = Letter
	if Letter == 'A' and IsNew:
		$VBoxContainer/CenterContainer/HBoxContainer/Label.set_visible(true)
		$VBoxContainer/CenterContainer/HBoxContainer/Label.text = '(Por Defecto)'


func get_is_new():
	return IsNew


func get_letter():
	return Letter


func create_again():
	set_visible(true)


func delete():
	set_visible(false)
