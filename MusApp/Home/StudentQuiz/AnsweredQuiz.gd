extends CenterContainer

var QuizLabel
var TeacherLabel
var ScoreLabel
var TimeLeftLabel
var QuizGrade
var Quiz
var Answer

func _ready():
	QuizLabel = $VBoxContainer/VBoxContainer/QuizBox/QuizLabel
	TeacherLabel = $VBoxContainer/VBoxContainer/TeacherBox/TeacherLabel
	ScoreLabel = $VBoxContainer/VBoxContainer2/ScoreBox/ScoreLabel
	TimeLeftLabel = $VBoxContainer/VBoxContainer2/TimeBox/TimeLeftLabel
	QuizGrade = $VBoxContainer/VBoxContainer3/GradeBox/GradeLabel

func fullname(User):
	return User['first_name'] + ' ' + User['middle_name'] + ' ' + User['last_name'] + ' ' + User['mothers_maiden_name']


func setup(quiz):
	Quiz = quiz['quiz']
	Answer =  quiz['answer']
	QuizLabel.text = Quiz['name']
	TeacherLabel.text = fullname(Quiz['teacher_id'])
	ScoreLabel.text = str(Answer['score_obtained'])
	TimeLeftLabel.text = str(Quiz['ended_time'] -  Answer['time_left']) + ' min'
	if Answer['is_checked']:
		if Answer['quiz_grade'].to_float() >= Quiz['aprobal_quiz_grade'].to_float():
			QuizGrade.set('theme_override_colors/font_color', Color.GREEN)
		else:
			QuizGrade.set('theme_override_colors/font_color', Color.DARK_RED)
		QuizGrade.text = Answer['quiz_grade']
	else:
		ScoreLabel.text = 'Sin Puntaje'
		QuizGrade.text = 'Sin Nota'
