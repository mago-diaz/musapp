extends CenterContainer

var FullNameLabel
var FullName
var Grade
var Student
var EditScreen
var GradesInLevels
var DeleteScreen

var Token
# Called when the node enters the scene tree for the first time.
func _ready():
	FullNameLabel = $VBoxContainer/VBoxContainer/StudentBox/StudentLabel
	Grade = $VBoxContainer/VBoxContainer/StudentBox/LevelAndGrade


func setup(student, grades_in_leves, edit_screen, delete_screen, token):
	Student = student
	FullName = student['first_name'] + " " + student['middle_name'] + " " + student['last_name'] + " " + student['mothers_maiden_name']
	FullNameLabel.text = FullName
	Grade.text = student['grade_id']['id_level']['number'] + " " + student['grade_id']['id_level']['type'] + " " +  student['grade_id']['letter']
	EditScreen = edit_screen
	GradesInLevels = grades_in_leves
	Token = token
	DeleteScreen = delete_screen


func get_name():
	return FullName


func _on_edit_student_pressed():
	EditScreen.setup(Student, GradesInLevels, Token)
	EditScreen.open()


func _on_delete_student_pressed():
	DeleteScreen.setup(Student, Token)
	DeleteScreen.open()
