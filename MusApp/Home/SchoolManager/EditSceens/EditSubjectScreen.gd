extends Control


const base_url = "http://127.0.0.1:8000/"
var http_subject_request

var IsCreated
var Token

var NewSubject
var SubjectId
var NameSubject
var NameSubjectEdit
var NameSubjectWarning

var GradeId
var LevelAndGradeEdit

var Teachers
var TeacherName
var TeacherOptions
var TeacherWarning

var DescriptionSubjectEdit
var DescriptionSubjectWarning

var Students
var StudentList
var CreateStudentInstantiate
var StudentListWarning

var SubjectCenter
var SendSubjectToServer
var SubjectSaved

func _ready():
	http_subject_request = HTTPRequest.new()
	add_child(http_subject_request)
	http_subject_request.connect("request_completed", self._http_subject_request_completed)
	
	NameSubjectEdit = $CenterContainer/VBoxContainer/NameBox/NameEdit
	NameSubjectWarning = $CenterContainer/VBoxContainer/NameWarning

	LevelAndGradeEdit = $CenterContainer/VBoxContainer/LevelAndGradeBox/LevelAndGradeEdit

	TeacherOptions = $CenterContainer/VBoxContainer/TeacherBox/TeacherOptions
	TeacherWarning = $CenterContainer/VBoxContainer/TeacherWarning

	DescriptionSubjectEdit = $CenterContainer/VBoxContainer/DescriptionBox/DescriptionEdit
	DescriptionSubjectWarning = $CenterContainer/VBoxContainer/DescriptionWarning

	StudentList = $CenterContainer/VBoxContainer/ColorRect/ScrollContainer/StudentList
	StudentListWarning = $CenterContainer/VBoxContainer/StudentListWarning
	
	SubjectCenter = $CenterContainer
	SendSubjectToServer = $SendLevelToServer
	SubjectSaved = $SubjectSaved


func clear_options(MyOptionButton):
	for i in range(MyOptionButton.get_item_count()-1, 0, -1 ):
		MyOptionButton.remove_item(i)

func fullname(User):
	return User['first_name'] + ' ' + User['middle_name'] + ' ' + User['last_name'] + ' ' + User['mothers_maiden_name']


func setup(subject, is_created, teachers, students, grade_name, grade_id, token):
	Teachers = {}
	Students = {}
	IsCreated = is_created
	TeacherName = ''
	Token = token
	NewSubject = {'name' : '', 'description' : '', 'teacher_id' : null, 'grade_id' : null, 'students' : []}
	Token = token
	var count = 1
	clear_options(TeacherOptions)
	for teacher in teachers:
		var TeacherFullName = fullname(teacher)
		Teachers[TeacherFullName] = teacher['id']
		TeacherOptions.add_item(TeacherFullName)
		if not IsCreated:
			if fullname(subject['teacher_id']) == TeacherFullName:
				TeacherOptions.select(count)
				_on_teacher_options_item_selected(count)
				NewSubject['teacher_id'] = Teachers[TeacherFullName]
		count += 1
	if IsCreated and TeacherOptions.get_item_count() > 1:
		_on_teacher_options_item_selected(1)
	
	count = 1
	for student in students:
		CreateStudentInstantiate = preload("res://Home/SchoolManager/EditSceens/CreateStudentOption.tscn").instantiate()
		StudentList.add_child(CreateStudentInstantiate)
		var StudentName = fullname(student)
		CreateStudentInstantiate.setup(StudentName, student['id'])
		Students[StudentName] = student['id']
		if not IsCreated:
			CreateStudentInstantiate.set_Select(Students[StudentName] in subject['students'])
		else:
			CreateStudentInstantiate.set_Select(false)
	
	LevelAndGradeEdit.text = grade_name
	GradeId = grade_id
	
	if IsCreated:
		NameSubjectEdit.set_editable(true)
	
	else:
		SubjectId = subject['id']
		NameSubjectEdit.set_editable(false)
		NameSubject = subject['name']
		NameSubjectEdit.text = NameSubject
		DescriptionSubjectEdit.text = subject['description']


func open():
	set_visible(true)
	SubjectCenter.set_visible(true)
	SendSubjectToServer.set_visible(false)
	SubjectSaved.set_visible(false)


func _on_select_all_student_pressed():
	for student in StudentList.get_children():
		student.set_Select(true)


func _on_name_edit_text_changed(new_text):
	NameSubject = new_text


func _on_save_edit_subject_pressed():
	var HasErrors = false
	var NewStudent = []
	for student in StudentList.get_children():
		var id = student.get_id()
		if id:
			NewStudent += [id] 
	if NewStudent == []:
		HasErrors = true
		StudentListWarning.text = 'debes seleccionar al menos un estudiante'
	
	if NameSubject == '':
		HasErrors = true
		NameSubjectWarning.text = 'la asignatura debe tener un nombre'
	
	if TeacherName == '':
		HasErrors = true
		TeacherWarning.text = 'debes seleccionar un profesor'
	
	if not HasErrors:
		NewSubject['name'] = NameSubject
		NewSubject['description'] = DescriptionSubjectEdit.get_text()
		NewSubject['teacher_id'] = Teachers[TeacherName]
		NewSubject['grade_id'] = GradeId
		NewSubject['students'] = NewStudent
		var token_header = "Authorization: Token " + Token
		var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
		var body = JSON.stringify(NewSubject)
		print(NewSubject)
		if IsCreated:
			var error = http_subject_request.request(base_url + "api/subjects/", headers, false, HTTPClient.METHOD_POST, body)
			if error != OK:
				push_error("An error ocurred in the HTTP request.")
		else: 
			var error = http_subject_request.request(base_url + "api/subjects/" + str(SubjectId) + "/" , headers, false, HTTPClient.METHOD_PATCH, body)
			if error != OK:
				push_error("An error ocurred in the HTTP request.")
		SubjectCenter.set_visible(false)
		SendSubjectToServer.set_visible(true)


func _http_subject_request_completed(result, response_code, headers, body):
	if result == http_subject_request.RESULT_SUCCESS:
		if response_code == 200:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response = json.get_data()
			print(response)
			SendSubjectToServer.set_visible(false)
			SubjectSaved.set_visible(true)


func _on_teacher_options_item_selected(index):
	TeacherName = TeacherOptions.get_item_text(index)


func _on_go_to_pressed():
	NameSubject = ''
	NameSubjectEdit.text = ''
	NameSubjectWarning.text = ''
	clear_options(TeacherOptions)
	TeacherName = ''
	TeacherWarning.text = ''
	Teachers = {}
	Students = {}
	DescriptionSubjectEdit.text = ''
	SubjectId = null
	Token = null
	TeacherName = ''
	NewSubject = {'name' : '', 'description' : '', 'teacher_id' : null, 'grade_id' : null, 'students' : []}
	for student in StudentList.get_children():
		StudentList.remove_child(student)
		student.queue_free()
	StudentListWarning.text = ''
	SubjectSaved.set_visible(false)
	set_visible(false)
	var parent = get_parent()
	if parent:
		parent.get_school_admin_profile()


func _on_exit_edit_subject_pressed():
	NameSubject = ''
	NameSubjectEdit.text = ''
	NameSubjectWarning.text = ''
	clear_options(TeacherOptions)
	TeacherName = ''
	TeacherWarning.text = ''
	Teachers = {}
	Students = {}
	DescriptionSubjectEdit.text = ''
	SubjectId = null
	Token = null
	TeacherName = ''
	NewSubject = {'name' : '', 'description' : '', 'teacher_id' : null, 'grade_id' : null, 'students' : []}
	for student in StudentList.get_children():
		StudentList.remove_child(student)
		student.queue_free()
	StudentListWarning.text = ''
	set_visible(false)
