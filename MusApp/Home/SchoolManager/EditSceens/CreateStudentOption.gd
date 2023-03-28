extends Control

var StudentName
var StudentNameLabel
var StudentID
var IsSelected = false

var CheckStudent


func _ready():
	CheckStudent = $VBoxContainer/CenterContainer/CheckBox
	StudentNameLabel = $VBoxContainer/VBoxContainer/StudentBox/StudentLabel


func setup(student_name, student_id):
	StudentName = student_name
	StudentID = student_id
	StudentNameLabel.text = StudentName
	

func get_id():
	if IsSelected:
		return StudentID
	else:
		return null


func set_Select(select):
	CheckStudent.set_pressed(select)


func _on_check_box_toggled(button_pressed):
	IsSelected = button_pressed
	print(IsSelected)
