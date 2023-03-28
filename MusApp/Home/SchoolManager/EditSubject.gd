extends CenterContainer

var Subject
var Teachers
var Students
var TeacherName

var SubjectLabel
var TeacherLabel

var GradeName
var GradeId

var EditScreen
var DeleteScreen
var Token

func _ready():
	SubjectLabel = $VBoxContainer/VBoxContainer/SubjectBox/SubjectLabel
	TeacherLabel = $VBoxContainer/VBoxContainer/SubjectBox/TeacherLabel


func setup(subject, teachers, students, grade_name, grade_id, edit_screen, delete_screen, token):
	Subject = subject
	SubjectLabel.text = Subject['name']
	var Teacher = Subject['teacher_id']
	TeacherName = Teacher['first_name'] + ' ' + Teacher['middle_name'] + ' ' + Teacher['last_name'] + ' ' + Teacher['mothers_maiden_name']
	TeacherLabel.text = TeacherName
	EditScreen = edit_screen
	DeleteScreen = delete_screen
	Teachers = teachers
	Students = students
	GradeName = grade_name
	GradeId = grade_id
	Token = token


func get_name():
	return Subject['name']


func _on_edit_subject_pressed():
	EditScreen.setup(Subject, false, Teachers, Students, GradeName, GradeId, Token)
	EditScreen.open()
	EditScreen.set_visible(true)


func _on_delete_subject_pressed():
	DeleteScreen.setup(Subject['name'], Subject['id'], Token)
	DeleteScreen.open()
