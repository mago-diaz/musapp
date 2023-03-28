from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from school_manager import models as sm_models, serializers as sm_serializer
from quiz import models, serializers

from rest_framework import status

class QuizApiView(APIView):
    
    def get(self, request, format = None):
        quizzes = models.Quiz.objects.all()


class TeacherQuizApiView(APIView):
    def get(self, request, pk = None, format = None):
        permission_classes = [IsAuthenticated]
        try:
            user = sm_models.Teacher.objects.get(email = request.user)
        except sm_models.Teacher.DoesNotExist:
            return Response({"error" :"Usuario Invalido"})
        if not pk:
            return Response({"error" :"Proporcione el id de la Prueba"})
        else:
            quizzes = models.Quiz.objects.filter(id = pk)
        quizzes_serializer = serializers.QuizSerializer(quizzes, many = True)
        return Response(quizzes_serializer.data)

    def post(self, request, format = None):
        permission_classes = [IsAuthenticated]
        try:
            user = sm_models.Teacher.objects.get(email = request.user)
        except sm_models.Teacher.DoesNotExist:
            return Response({"error" :"Usuario Invalido"})
        quiz_serializer = serializers.QuizSerializer(data = request.data.get("quiz"))
        if not quiz_serializer.is_valid():
            return Response(quiz_serializer.errors)
        
        quiz_serializer.save()
        for question in request.data.get("questions"):
            new_question = {}
            new_question['quiz_id'] = quiz_serializer.data.get("id")
            new_question['number'] = question['Number']
            new_question['question'] = question['Question']
            new_question['score'] = question['Score']
            if question['TypeOfQuestion'] == "TOF":
                new_question['correct_answer'] = question['CorrectAnswer']
                new_question_serializer = serializers.TOFQuestionSerializer(data = new_question)
                if new_question_serializer.is_valid():
                    new_question_serializer.save()
            elif question['TypeOfQuestion'] == "Selection":
                new_question['options'] = question['Options']
                new_question['correct_answer'] = question['CorrectAnswer']
                new_question_serializer = serializers.SelectionQuestionSerializer(data = new_question)
                if new_question_serializer.is_valid():
                    new_question_serializer.save()
            elif question['TypeOfQuestion'] == "Writting":
                new_question['rubric'] = question['Rubric']
                new_question_serializer = serializers.WrittingQuestionSerializer(data = new_question)
                print(new_question)
                if new_question_serializer.is_valid():
                    new_question_serializer.save()
            elif question['TypeOfQuestion'] == "Piano":
                new_question['visiblepiano'] = question['Setup']
                new_question['rubric'] = question['Rubric']
                new_question_serializer = serializers.PianoQuestionSerializer(data = new_question)
                if new_question_serializer.is_valid():
                    new_question_serializer.save()
            elif question['TypeOfQuestion'] == "MusicSheet":
                new_question['rubric'] = question['Rubric']
                new_question_serializer = serializers.MusicSheetQuestionSerializer(data = new_question)
                if new_question_serializer.is_valid():
                    new_question_serializer.save()
        return Response(quiz_serializer.data)

    def patch(self, request, pk):
        quiz = models.Quiz.objects.filter(id = pk).first()
        quiz_serializer = serializers.QuizSerializer(quiz, data = request.data, partial = True)
        if quiz_serializer.is_valid():
            quiz_serializer.save()
            return Response(quiz_serializer.data)
        return Response({"error" :" los parámetros no han sido enviados correctamente"}, status=status.HTTP_400_BAD_REQUEST)




class StudentQuizApiView(APIView):
    def get(self, request, pk):
        permission_classes = [IsAuthenticated]
        try:
            user = sm_models.Student.objects.get(email = request.user)
        except sm_models.Student.DoesNotExist:      
            return Response({"error" :"Usuario Invalido"})
        if not pk:
            return Response({"error" :"Proporcione el id de la Prueba"})
        dictionary = {}
        quiz = models.Quiz.objects.filter(id = pk).first()
        quiz_serializer = serializers.QuizSerializer(quiz)

        tof_question = models.TOFQuestion.objects.filter(quiz_id = quiz.id)
        tof_question_serializer = serializers.TOFQuestionStudentSerializer(tof_question, many = True)

        selection_question = models.SelectionQuestion.objects.filter(quiz_id = quiz.id)
        selection_question_serializer = serializers.SelectionQuestionStudentSerializer(selection_question, many = True)

        writting_question = models.WrittingQuestion.objects.filter(quiz_id = quiz.id)
        writting_question_serializer = serializers.WrittingQuestionSerializer(writting_question, many = True)

        piano_question = models.PianoQuestion.objects.filter(quiz_id = quiz.id)
        piano_question_serializer = serializers.PianoQuestionStudentSerializer(piano_question, many = True)

        music_sheet_question = models.MusicSheetQuestion.objects.filter(quiz_id = quiz.id)
        music_sheet_question_serializer = serializers.MusicSheetQuestionStudentSerializer(music_sheet_question, many = True)

        return Response({'quiz' : quiz_serializer.data, 'tof_questions' : tof_question_serializer.data, 'selection_questions' : selection_question_serializer.data, 
                        'writting_questions' : writting_question_serializer.data, 'piano_questions' : piano_question_serializer.data, 'music_sheet_questions' : music_sheet_question_serializer.data})

    def post(self, request, format = None):
        permission_classes = [IsAuthenticated]
        try:
            user = sm_models.Student.objects.get(email = request.user)
        except sm_models.Student.DoesNotExist:      
            return Response({"error" :"Usuario Invalido"})

        answer_quiz_serializer = serializers.AnsweredQuizSerializer(data = request.data)
        if not answer_quiz_serializer.is_valid():
            return Response(answer_quiz_serializer.errors)
        
        answer_quiz_serializer.save()
        return Response({'answered_quiz_id' : answer_quiz_serializer.data.get('id'), 'time_left' : answer_quiz_serializer.data.get('time_left')})


    def patch(self, request, pk):
        permission_classes = [IsAuthenticated]
        try:
            user = sm_models.Student.objects.get(email = request.user)
        except sm_models.Student.DoesNotExist:      
            return Response({"error" :"Usuario Invalido"})
        answered_quiz = models.AnsweredQuiz.objects.filter(id = pk, student_id = user.id).first()
        answered_quiz_serializer = serializers.AnsweredQuizSerializer(answered_quiz, data = request.data, partial = True)
        if answered_quiz_serializer.is_valid():
            answered_quiz_serializer.save()
            return Response({'answered_quiz_id' : answered_quiz_serializer.data.get('id'), 'time_left' : answered_quiz_serializer.data.get('time_left')})

        return Response({"error" :" los parámetros no han sido enviados correctamente"}, status=status.HTTP_400_BAD_REQUEST)




class StudentAnsweredQuestionsApiView(APIView):
    def get(self, request, pk):
        permission_classes = [IsAuthenticated]
        try:
            user = sm_models.Student.objects.get(email = request.user)
        except sm_models.Student.DoesNotExist:      
            return Response({"error" :"Usuario Invalido"})
        if not pk:
            return Response({"error" :"Proporcione el id de la Prueba"})
        dictionary = {}
        answered_quiz = models.AnsweredQuiz.objects.filter(id = pk, student_id = user.id).first()
        answered_quiz_serializer = serializers.AnsweredQuizSerializer(answered_quiz)

        tof_answered = models.AnsweredTOFQuestion.objects.filter(answered_quiz_id = answered_quiz.id)
        tof_answered_serializer = serializers.AnsweredTOFQuestionSerializer(tof_answered, many = True)

        selection_answered = models.AnsweredSelectionQuestion.objects.filter(answered_quiz_id = answered_quiz.id)
        selection_answered_serializer = serializers.AnsweredSelectionQuestionSerializer(selection_answered, many = True)

        writting_answered = models.AnsweredWrittingQuestion.objects.filter(answered_quiz_id = answered_quiz.id)
        writting_answered_serializer = serializers.AnsweredWrittingQuestionSerializer(writting_answered, many = True)

        piano_answered = models.AnsweredPianoQuestion.objects.filter(answered_quiz_id = answered_quiz.id)
        piano_answered_serializer = serializers.AnsweredPianoQuestionSerializer(piano_answered, many = True)

        music_sheet_answered = models.AnsweredMusicSheetQuestion.objects.filter(answered_quiz_id = answered_quiz.id)
        music_sheet_answered_serializer = serializers.AnsweredMusicSheetQuestionSerializer(music_sheet_answered, many = True)

        return Response({'answered_quiz' : answered_quiz_serializer.data, 'tof_answered' : tof_answered_serializer.data, 'selection_answered' : selection_answered_serializer.data,
                'writting_answered' : writting_answered_serializer.data, 'piano_asnwered' : piano_answered_serializer.data, 'music_sheet_answered' : music_sheet_answered_serializer.data})    


    def post(self, request, pk):
        permission_classes = [IsAuthenticated]
        try:
            user = sm_models.Student.objects.get(email = request.user)
        except sm_models.Student.DoesNotExist:      
            return Response({"error" :"Usuario Invalido"})
        answered_quiz = models.AnsweredQuiz.objects.filter(id = pk, student_id = user.id).first()

        for tof_answer in request.data.get("tof_answers"): 
            new_answer = {}
            new_answer['answered_quiz_id'] = answered_quiz.id
            new_answer['question_id'] = tof_answer['question_id']
            new_answer['answer'] = tof_answer['answer']
            new_answer['comments'] = ""
            new_answer['score'] = 0
            new_answer_serializer = serializers.AnsweredTOFQuestionSerializer(data = new_answer)
            if new_answer_serializer.is_valid():
                new_answer_serializer.save()
            else:
                return Response(new_answer_serializer.errors)

        for selection_answer in request.data.get("selection_answers"): 
            new_answer = {}
            new_answer['answered_quiz_id'] =  answered_quiz.id
            new_answer['question_id'] = selection_answer['question_id']
            new_answer['answer'] = selection_answer['answer']
            new_answer['comments'] = ""
            new_answer['score'] = 0
            new_answer_serializer = serializers.AnsweredSelectionQuestionSerializer(data = new_answer)
            if new_answer_serializer.is_valid():
                new_answer_serializer.save()
            else:
                return Response(new_answer_serializer.errors)
        
        for writting_answer in request.data.get("writting_answers"): 
            new_answer = {}
            new_answer['answered_quiz_id'] =  answered_quiz.id
            new_answer['question_id'] = writting_answer['question_id']
            new_answer['answer'] = writting_answer['answer']
            new_answer['comments'] = ""
            new_answer['score'] = 0
            new_answer_serializer = serializers.AnsweredWrittingQuestionSerializer(data = new_answer)
            if new_answer_serializer.is_valid():
                new_answer_serializer.save()
            else:
                return Response(new_answer_serializer.errors)
        
        for piano_answer in request.data.get("piano_answers"): 
            new_answer = {}
            new_answer['answered_quiz_id'] =  answered_quiz.id
            new_answer['question_id'] = piano_answer['question_id']
            new_answer['answer'] = piano_answer['answer']
            new_answer['comments'] = ""
            new_answer['score'] = 0
            new_answer_serializer = serializers.AnsweredPianoQuestionSerializer(data = new_answer)
            if new_answer_serializer.is_valid():
                new_answer_serializer.save()
            else:
                return Response(new_answer_serializer.errors)
        
        for music_sheet_answer in request.data.get("music_sheet_answers"): 
            new_answer = {}
            new_answer['answered_quiz_id'] = answered_quiz.id
            new_answer['question_id'] = music_sheet_answer['question_id']
            new_answer['answer'] = music_sheet_answer['answer']
            new_answer['comments'] = ""
            new_answer['score'] = 0
            new_answer_serializer = serializers.AnsweredMusicSheetQuestionSerializer(data = new_answer)
            if new_answer_serializer.is_valid():
                new_answer_serializer.save()
            else:
                return Response(new_answer_serializer.errors)

        return Response({"message" : "Evaluación guardada con exito"})


class CheckAnsweredQuizbyTeacherApiView(APIView):
    def get(self, request, pk):
        permission_classes = [IsAuthenticated]
        try:
            user = sm_models.Teacher.objects.get(email = request.user)
        except sm_models.Teacher.DoesNotExist:      
            return Response({"error" :"Usuario Invalido"})
        if not pk:
            return Response({"error" :"Proporcione el id de la Prueba"})
        dictionary = {}
        answered_quiz = models.AnsweredQuiz.objects.filter(id = pk).first()
        answered_quiz_serializer = serializers.AnsweredQuizSerializer(answered_quiz)

        tof_answered = models.AnsweredTOFQuestion.objects.filter(answered_quiz_id = answered_quiz.id)
        tof_answered_serializer = serializers.AnsweredTOFQuestionTeacherSerializer(tof_answered, many = True)

        selection_answered = models.AnsweredSelectionQuestion.objects.filter(answered_quiz_id = answered_quiz.id)
        selection_answered_serializer = serializers.AnsweredSelectionQuestionTeacherSerializer(selection_answered, many = True)

        writting_answered = models.AnsweredWrittingQuestion.objects.filter(answered_quiz_id = answered_quiz.id)
        writting_answered_serializer = serializers.AnsweredWrittingQuestionTeacherSerializer(writting_answered, many = True)

        piano_answered = models.AnsweredPianoQuestion.objects.filter(answered_quiz_id = answered_quiz.id)
        piano_answered_serializer = serializers.AnsweredPianoQuestionTeacherSerializer(piano_answered, many = True)

        music_sheet_answered = models.AnsweredMusicSheetQuestion.objects.filter(answered_quiz_id = answered_quiz.id)
        music_sheet_answered_serializer = serializers.AnsweredMusicSheetQuestionTeacherSerializer(music_sheet_answered, many = True)

        return Response({'answered_quiz' : answered_quiz_serializer.data, 'tof_answered' : tof_answered_serializer.data, 'selection_answered' : selection_answered_serializer.data,
                'writting_answered' : writting_answered_serializer.data, 'piano_answered' : piano_answered_serializer.data, 'music_sheet_answered' : music_sheet_answered_serializer.data})    


    def post(self, request, format = None):
        permission_classes = [IsAuthenticated]
        try:
            user = sm_models.Teacher.objects.get(email = request.user)
        except sm_models.Teacher.DoesNotExist:      
            return Response({"error" : "Usuario Invalido"})

        answer_quiz_serializer = serializers.AnsweredQuizSerializer(data = request.data)
        if not answer_quiz_serializer.is_valid():
            return Response(answer_quiz_serializer.errors)
        answer_quiz_serializer.save()

        quiz = models.Quiz.objects.filter(id = request.data.get('quiz_id')).first()
        quiz_serializer = serializers.QuizSerializer(quiz)
        subject_id = quiz_serializer.data.get('subject')
        subject = sm_models.Subject.objects.filter(id = subject_id).first()
        subject_serializer = sm_serializer.SubjectSerializer(subject)
        student_and_answers = []

        for student_id in subject_serializer.data.get('students'):
            student = sm_models.Student.objects.filter(id = student_id).first()
            student_serializer = sm_serializer.StudentNameSerializer(student)
            answered_quiz = models.AnsweredQuiz.objects.filter(quiz_id = request.data.get('quiz_id'), student_id = student_id).first()
            answered_quiz_serializer = serializers.AnsweredQuizSerializer(answered_quiz)
            student_and_answers += [{'student' : student_serializer.data, 'answered_quiz' : answered_quiz_serializer.data}]
        return Response({'student' : student_and_answers})

    
    def patch(self, request, pk, format = None):
        permission_classes = [IsAuthenticated]
        try:
            user = sm_models.Teacher.objects.get(email = request.user)
        except sm_models.Teacher.DoesNotExist:      
            return Response({"error" :"Usuario Invalido"})
        answered_quiz = models.AnsweredQuiz.objects.filter(id = pk).first()
        answered_quiz_serializer = serializers.AnsweredQuizSerializer(answered_quiz, data = request.data.get('answered_quiz'), partial = True)
        if answered_quiz_serializer.is_valid():
            answered_quiz_serializer.save()
        else:
            return Response(answered_quiz_serializer.errors)

        for tof_answer in request.data.get("tof_answers"): 
            new_tof_answer = models.AnsweredTOFQuestion.objects.filter(answered_quiz_id = answered_quiz.id, question_id = tof_answer['question_id']).first()
            new_tof_answer_serializer = serializers.AnsweredTOFQuestionSerializer(new_tof_answer, data = tof_answer['answer'], partial = True)
            if new_tof_answer_serializer.is_valid():
                new_tof_answer_serializer.save()

        for selection_answer in request.data.get("selection_answers"): 
            new_selection_answer = models.AnsweredSelectionQuestion.objects.filter(answered_quiz_id = answered_quiz.id, question_id = selection_answer['question_id']).first()
            new_selection_answer_serializer = serializers.AnsweredSelectionQuestionSerializer(new_selection_answer, data = selection_answer['answer'], partial = True)
            if new_selection_answer_serializer.is_valid():
                new_selection_answer_serializer.save()
        
        for writting_answer in request.data.get("writting_answers"): 
            new_writting_answer = models.AnsweredWrittingQuestion.objects.filter(answered_quiz_id = answered_quiz.id, question_id = writting_answer['question_id']).first()
            new_writting_answer_serializer = serializers.AnsweredWrittingQuestionSerializer(new_writting_answer, data = writting_answer['answer'], partial = True)
            if new_writting_answer_serializer.is_valid():
                new_writting_answer_serializer.save()
        
        for piano_answer in request.data.get("piano_answers"): 
            new_piano_answer = models.AnsweredPianoQuestion.objects.filter(answered_quiz_id = answered_quiz.id, question_id = piano_answer['question_id']).first()
            new_piano_answer_serializer = serializers.AnsweredPianoQuestionSerializer(new_piano_answer, data = piano_answer['answer'], partial = True)
            if new_piano_answer_serializer.is_valid():
                new_piano_answer_serializer.save()
        
        for music_sheet_answer in request.data.get("music_sheet_answers"): 
            new_music_sheet_answer = models.AnsweredMusicSheetQuestion.objects.filter(answered_quiz_id = answered_quiz.id, question_id = music_sheet_answer['question_id']).first()
            new_music_sheet_answer_serializer = serializers.AnsweredMusicSheetQuestionSerializer(new_music_sheet_answer, data = music_sheet_answer['answer'], partial = True)
            if new_music_sheet_answer_serializer.is_valid():
                new_music_sheet_answer_serializer.save()
        
        quiz_id  = answered_quiz_serializer.data.get('quiz_id')
        quiz = models.Quiz.objects.filter(id = quiz_id).first()
        quiz_serializer = serializers.QuizSerializer(quiz)
        subject_id = quiz_serializer.data.get('subject')
        subject = sm_models.Subject.objects.filter(id = subject_id).first()
        subject_serializer = sm_serializer.SubjectSerializer(subject)
        student_and_answers = []

        for student_id in subject_serializer.data.get('students'):
            student = sm_models.Student.objects.filter(id = student_id).first()
            student_serializer = sm_serializer.StudentNameSerializer(student)
            answered_quiz = models.AnsweredQuiz.objects.filter(quiz_id = quiz_id,student_id = student_id).first()
            answered_quiz_serializer = serializers.AnsweredQuizSerializer(answered_quiz)
            student_and_answers += [{'student' : student_serializer.data, 'answered_quiz' : answered_quiz_serializer.data}]
        return Response({'student' : student_and_answers})




class TeacherQuizzesBySubjectApiView(APIView):
    def get(self, request, pk = None, format = None):
        permission_classes = [IsAuthenticated]
        try:
            user = sm_models.Teacher.objects.get(email = request.user)
        except sm_models.Teacher.DoesNotExist:
            return Response({"error" :"Usuario Invalido"})
        dictionary = {}
        if not pk:
            subjects = sm_models.Subject.objects.filter(teacher_id = user.id)
        else:
            subjects = sm_models.Subject.objects.filter(id = pk)
        for subject in subjects: 
            inactive_quizzes = models.Quiz.objects.filter(teacher_id = user.id, subject = subject.id, is_active = False, is_ended = False)
            inactive_quizzes_serializer = serializers.QuizSerializer(inactive_quizzes, many = True)
            active_quizzes = models.Quiz.objects.filter(teacher_id = user.id, subject = subject.id, is_active = True, is_ended = False)
            active_quizzes_serializer = serializers.QuizSerializer(active_quizzes, many = True)
            ended_quizzes = models.Quiz.objects.filter(teacher_id = user.id, subject = subject.id, is_active = False, is_ended = True)
            ended_quizzes_serializer = serializers.QuizSerializer(ended_quizzes, many = True)
            dictionary[subject.id]=  {"inactive_quizzes" : inactive_quizzes_serializer.data, "active_quizzes" : active_quizzes_serializer.data, "ended_quizzes" : ended_quizzes_serializer.data}
        return Response(dictionary)




class StudentQuizzesBySubjectApiView(APIView):
    def get(self, request, pk = None, format = None):
        permission_classes = [IsAuthenticated]
        try:
            user = sm_models.Student.objects.get(email = request.user)
        except sm_models.Student.DoesNotExist:
            return Response({"error" :"Usuario Invalido"})
        dictionary = {}
        if not pk:
            subjects = sm_models.Subject.objects.filter(students = user.id)
        else:
            subjects = sm_models.Subject.objects.filter(id = pk)
        for subject in subjects:
            active_quizzes_list = []
            ended_quizzes_list = []
            active_quizzes = models.Quiz.objects.filter(subject = subject.id, is_active = True, is_ended = False)
            for active_quiz in active_quizzes:
                active_quiz_serializer = serializers.QuizSerializerWithTeacher(active_quiz)
                answer_quiz = models.AnsweredQuiz.objects.filter(quiz_id = active_quiz.id, student_id = user.id).first()
                if answer_quiz == None:
                    active_quizzes_list += [{'quiz' : active_quiz_serializer.data, 'answer' : None}]
                else:
                    answer_quiz_serializer = serializers.AnsweredQuizSerializer(answer_quiz)
                    active_quizzes_list += [{'quiz' : active_quiz_serializer.data, 'answer' : answer_quiz_serializer.data}]
            
            ended_quizzes = models.Quiz.objects.filter(subject = subject.id, is_active = False, is_ended = True)
            print(ended_quizzes)
            for ended_quiz in ended_quizzes:
                ended_quiz_serializer = serializers.QuizSerializerWithTeacher(ended_quiz)
                answer_quiz = models.AnsweredQuiz.objects.filter(quiz_id = ended_quiz.id, student_id = user.id).first()
                if answer_quiz == None:
                    ended_quizzes_list += [{'quiz' : ended_quiz_serializer.data, 'answer' : None}]
                else:
                    answer_quiz_serializer = serializers.AnsweredQuizSerializer(answer_quiz)
                    ended_quizzes_list += [{'quiz' : ended_quiz_serializer.data, 'answer' : answer_quiz_serializer.data}]

            dictionary[subject.id]= {"active_quizzes" : active_quizzes_list, "ended_quizzes" : ended_quizzes_list}
        return Response(dictionary)

    


class StudentAndAnswersByQuizApiView(APIView):
    def get(self, request, pk, format = None):
        permission_classes = [IsAuthenticated]
        try:
            user = sm_models.Teacher.objects.get(email = request.user)
        except sm_models.Teacher.DoesNotExist:
            return Response({"error" :"Usuario Invalido"})
        quiz = models.Quiz.objects.filter(id = pk).first()
        quiz_serializer = serializers.QuizSerializer(quiz)
        subject_id = quiz_serializer.data.get('subject')
        subject = sm_models.Subject.objects.filter(id = subject_id).first()
        subject_serializer = sm_serializer.SubjectSerializer(subject)
        student_and_answers = []

        for student_id in subject_serializer.data.get('students'):
            student = sm_models.Student.objects.filter(id = student_id).first()
            student_serializer = sm_serializer.StudentNameSerializer(student)
            answered_quiz = models.AnsweredQuiz.objects.filter(quiz_id = pk,student_id = student_id).first()
            answered_quiz_serializer = serializers.AnsweredQuizSerializer(answered_quiz)
            student_and_answers += [{'student' : student_serializer.data, 'answered_quiz' : answered_quiz_serializer.data}]
        return Response({'student' : student_and_answers})
