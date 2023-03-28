extends CenterContainer

var FullNameLabel
var FullName
var Teacher
var EditScreen
var Token
var DeleteScreen


func _ready():
	FullNameLabel = $VBoxContainer/VBoxContainer/TeacherBox/TeacherLabel

func setup(teacher, edit_screen, delete_screen, token):
	Teacher = teacher
	FullName = teacher['first_name'] + " " + teacher['middle_name'] + " " + teacher['last_name'] + " " + teacher['mothers_maiden_name']
	FullNameLabel.text = FullName
	EditScreen = edit_screen
	Token = token 
	DeleteScreen = delete_screen

func get_name():
	return FullName

func _on_edit_teacher_pressed():
	EditScreen.setup(Teacher, Token)
	EditScreen.open()


func _on_delete_teacher_pressed():
	DeleteScreen.setup(Teacher, Token)
	DeleteScreen.open()
