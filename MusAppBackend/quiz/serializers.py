from rest_framework import serializers
from quiz import models
from school_manager import serializers as sm_serializer

class QuizSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Quiz
        fields = '__all__'

class QuizSerializerWithTeacher(serializers.ModelSerializer):
    teacher_id = sm_serializer.TeacherNameSerializer()
    class Meta:
        model = models.Quiz
        fields = '__all__'


class TOFQuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.TOFQuestion
        fields = '__all__'

class SelectionQuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.SelectionQuestion
        fields = '__all__'

class WrittingQuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.WrittingQuestion
        fields = '__all__'

class PianoQuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.PianoQuestion
        fields = '__all__'

class MusicSheetQuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.MusicSheetQuestion
        fields = '__all__'




class TOFQuestionStudentSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.TOFQuestion
        exclude = ['correct_answer',]

class SelectionQuestionStudentSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.SelectionQuestion
        exclude = ['correct_answer',]

class WrittingQuestionStudentSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.WrittingQuestion
        fields = '__all__'

class PianoQuestionStudentSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.PianoQuestion
        fields = '__all__'

class MusicSheetQuestionStudentSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.MusicSheetQuestion
        fields = '__all__'


class AnsweredQuizSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.AnsweredQuiz
        fields = '__all__'

class AnsweredTOFQuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.AnsweredTOFQuestion
        fields = '__all__'

class AnsweredSelectionQuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.AnsweredSelectionQuestion
        fields = '__all__'

class AnsweredWrittingQuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.AnsweredWrittingQuestion
        fields = '__all__'

class AnsweredPianoQuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.AnsweredPianoQuestion
        fields = '__all__'

class AnsweredMusicSheetQuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.AnsweredMusicSheetQuestion
        fields = '__all__'




class AnsweredTOFQuestionTeacherSerializer(serializers.ModelSerializer):
    question_id = TOFQuestionSerializer()
    class Meta:
        model = models.AnsweredTOFQuestion
        fields = '__all__'

class AnsweredSelectionQuestionTeacherSerializer(serializers.ModelSerializer):
    question_id = SelectionQuestionSerializer()
    class Meta:
        model = models.AnsweredSelectionQuestion
        fields = '__all__'

class AnsweredWrittingQuestionTeacherSerializer(serializers.ModelSerializer):
    question_id = WrittingQuestionSerializer()
    class Meta:
        model = models.AnsweredWrittingQuestion
        fields = '__all__'

class AnsweredPianoQuestionTeacherSerializer(serializers.ModelSerializer):
    question_id = PianoQuestionSerializer()
    class Meta:
        model = models.AnsweredPianoQuestion
        fields = '__all__'

class AnsweredMusicSheetQuestionTeacherSerializer(serializers.ModelSerializer):
    question_id = MusicSheetQuestionSerializer()
    class Meta:
        model = models.AnsweredMusicSheetQuestion
        fields = '__all__'