extends Control

const base_url = "http://127.0.0.1:8000/"
var http_request_subject
var SubjectName
var SubjectId
var SubjectLabel
var Token

var DeleteSubject
var Deleting
var SubjectDeleted
var DeleteSubjectLabel

func _ready():
	SubjectLabel = $Deleted/CenterContainer/DeleteBox/Subject
	DeleteSubject = $Deleted/CenterContainer/DeleteBox
	Deleting = $Deleted/CenterContainer/Deleting
	SubjectDeleted = $Deleted/CenterContainer/SubjectDeleted
	DeleteSubjectLabel = $Deleted/CenterContainer/SubjectDeleted/Label
	
	http_request_subject = HTTPRequest.new()
	add_child(http_request_subject)
	http_request_subject.connect('request_completed', self._http_request_subject_completed)
	

func setup(subject_name, subject_id, token):
	SubjectName = subject_name
	SubjectId = subject_id
	SubjectLabel.text = 'Estas seguro de eliminar la asignatura : ' + SubjectName
	Token = token

func open():
	set_visible(true)
	DeleteSubject.set_visible(true)
	Deleting.set_visible(false)
	SubjectDeleted.set_visible(false)


func _on_back_pressed():
	SubjectLabel.text = ''
	SubjectId = null
	Token = null
	set_visible(false)


func _on_delete_level_pressed():
	DeleteSubject.set_visible(false)
	Deleting.set_visible(true)
	var token_header = "Authorization: Token " + Token
	var headers = ["Content-Type: application/json", "Accept: application/json", token_header]
	var error = http_request_subject.request(base_url + "api/subjects/" + str(SubjectId) + "/", headers, false, HTTPClient.METHOD_DELETE)
	if error != OK:
		push_error("An error ocurred in the HTTP request.")


func _http_request_subject_completed(result, response_code, headers, body):
	if result == http_request_subject.RESULT_SUCCESS:
		if response_code == 200:
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response = json.get_data()
			DeleteSubjectLabel.text = response['message']
			Deleting.set_visible(false)
			SubjectDeleted.set_visible(true)


func _on_exit_pressed():
	SubjectLabel.text = ''
	SubjectId = null
	Token = null
	set_visible(false)
	var parent = get_parent()
	if parent:
		parent.get_school_admin_profile()
