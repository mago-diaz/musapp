from django.db import models
from school_manager import models as sm_models



#### QUIZ & QUESTION MODELS ####

class Quiz(models.Model):
    name = models.CharField(max_length = 255)
    teacher_id = models.ForeignKey(sm_models.Teacher, on_delete = models.CASCADE)
    subject = models.ForeignKey(sm_models.Subject, on_delete = models.CASCADE)
    ended_date = models.CharField(max_length= 255)
    is_active = models.BooleanField(default = True)
    is_ended = models.BooleanField(default = False)
    total_score = models.IntegerField()
    min_quiz_grade = models.DecimalField(max_digits=3, decimal_places=2)
    aprobal_quiz_grade = models.DecimalField(max_digits=3, decimal_places=2)
    max_quiz_grade = models.DecimalField(max_digits=3, decimal_places=2)
    scale = models.DecimalField(max_digits=3, decimal_places=2)
    ended_time = models.IntegerField()
    number_of_questions = models.IntegerField()


class Question(models.Model):
    class Meta:
        abstract = True

    quiz_id = models.ForeignKey(Quiz, on_delete = models.CASCADE)
    number = models.IntegerField()
    question = models.TextField(max_length = 500)
    score = models.IntegerField()

class TOFQuestion(Question):
    correct_answer = models.BooleanField()

class SelectionQuestion(Question):
    correct_answer = models.CharField(max_length = 255)
    score = models.IntegerField()
    options = models.JSONField()

class WrittingQuestion(Question):
    rubric = models.TextField(blank = True)

class PianoQuestion(Question):
    visiblepiano = models.BooleanField(default = True)
    rubric = models.TextField(blank = True)


class MusicSheetQuestion(Question):
    rubric = models.TextField(blank = True)


#### ANSWER MODELS ####

class AnsweredQuiz(models.Model):
    quiz_id = models.ForeignKey(Quiz, on_delete = models.CASCADE)
    student_id = models.ForeignKey(sm_models.Student, on_delete = models.CASCADE)
    subject = models.ForeignKey(sm_models.Subject, on_delete = models.CASCADE)
    score_obtained = models.IntegerField()
    comments = models.TextField(blank=True)
    quiz_grade = models.DecimalField(max_digits=3, decimal_places=2)
    time_left = models.IntegerField()
    is_checked = models.BooleanField(default=False)
    create_by_teacher = models.BooleanField(default=False)
    

class AnsweredQuestion(models.Model):
    class Meta:
        abstract = True
    answered_quiz_id = models.ForeignKey(AnsweredQuiz, on_delete = models.CASCADE)
    comments = models.TextField(blank=True)
    score = models.IntegerField()
    

class AnsweredTOFQuestion(AnsweredQuestion):
    question_id = models.ForeignKey(TOFQuestion, on_delete = models.CASCADE)
    answer = models.CharField(max_length = 255, blank=True)


class AnsweredSelectionQuestion(AnsweredQuestion):
    question_id = models.ForeignKey(SelectionQuestion, on_delete = models.CASCADE)
    answer = models.CharField(max_length = 255, blank=True)


class AnsweredWrittingQuestion(AnsweredQuestion):
    question_id = models.ForeignKey(WrittingQuestion, on_delete = models.CASCADE)
    answer = models.TextField(blank=True, max_length=500)

class AnsweredPianoQuestion(AnsweredQuestion):
    question_id = models.ForeignKey(PianoQuestion, on_delete = models.CASCADE)
    answer = models.JSONField()

class AnsweredMusicSheetQuestion(AnsweredQuestion):
    question_id = models.ForeignKey(MusicSheetQuestion, on_delete = models.CASCADE)
    answer = models.JSONField()