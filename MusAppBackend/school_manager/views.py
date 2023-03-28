from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from django.contrib.auth import logout
from django.contrib.auth.hashers import check_password
from rest_framework.permissions import IsAuthenticated


from rest_framework import status

from school_manager import models, serializers


class CreateUserApiView(APIView):
    def post(self, request, format = None):
        if request.data.get('type') == models.UserAccount.Types.TEACHER:
            teacher_serializer = serializers.TeacherSerializer(data = request.data)
            if not teacher_serializer.is_valid():
                return Response(teacher_serializer.errors)
            teacher_serializer.save()
            return Response({'teacher' : teacher_serializer.data})
        
        elif request.data.get('type') == models.UserAccount.Types.STUDENT:
            student_serializer = serializers.StudentSerializer(data = request.data)
            if not student_serializer.is_valid():
                return Response(student_serializer.errors)
            student_serializer.save()
            return Response({'student' : student_serializer.data})
        else:
            return Response({'error' : 'debes seleccionar una ocupación'})


class LoginApiView(APIView):
    def post(self, request, format = None):
        email = request.data.get("email")
        password = request.data.get("password")
        try:
            user = models.UserAccount.objects.get(email = email)
        except models.UserAccount.DoesNotExist:
            return Response({"error" :"Usuario Invalido"}, status=status.HTTP_400_BAD_REQUEST)
        if not check_password(password, user.password):
            return Response({"error" : "Contraseña Invalida"}, status=status.HTTP_401_UNAUTHORIZED)
        else:
            token, created = Token.objects.get_or_create(user = user)
            return Response({"token" : token.key, "type" : user.type},  status=status.HTTP_200_OK)


class LogoutApiView(APIView):
    def get(self, request, format = None):
        permission_classes = [IsAuthenticated]
        request.user.auth_token.delete()
        logout(request)
        return Response({"message" : "Has cerrado sesion"},  status= status.HTTP_200_OK)
    

class ProfileStudentApiView(APIView):
    def get(self, request, format = None):
        permission_classes = [IsAuthenticated]
        user = models.Student.objects.get(email = request.user)
        user_serializer = serializers.StudentNameSerializer(user, many = False)
        subjects = models.Subject.objects.filter(students = user.id)
        subject_serializer  = serializers.SubjectWithTeacherSerializer(subjects, many = True)
        return Response({"student" : user_serializer.data, "subjects" : subject_serializer.data})      
    
    def patch(self, request, pk):
        permission_classes = [IsAuthenticated]
        try:
            user = models.UserAccount.objects.get(email = request.user)
        except models.UserAccount.DoesNotExist or user.type != models.UserAccount.Types.SCHOOL_ADMIN:
            return Response({"error" :"Usuario Invalido"})
        student = models.Student.objects.filter(id = pk).first()
        student_serializer = serializers.StudentSerializer(student, data = request.data, partial = True)
        if student_serializer.is_valid():
            student_serializer.save()
            return Response({'student' : student_serializer.data})
        else:
            return Response(student_serializer.errors)

    def delete(self, request, pk, format = None):
        permission_classes = [IsAuthenticated]
        try:
            user = models.UserAccount.objects.get(email = request.user)
        except models.UserAccount.DoesNotExist or user.type != models.UserAccount.Types.SCHOOL_ADMIN:
            return Response({"error" :"Usuario Invalido"})
        student = models.Student.objects.filter(id = pk).first()
        student.delete()
        return Response({'message' : 'Estudiante eliminado'})


class ProfileTeacherApiView(APIView):
    def get(self, request, format = None):
        permission_classes = [IsAuthenticated]
        user = models.Teacher.objects.get(email = request.user)
        user_serializer = serializers.TeacherSerializer(user, many = False)
        subjects = models.Subject.objects.filter(teacher_id = user.id)
        subject_serializer  = serializers.SubjectWithTeacherSerializer(subjects, many = True)
        return Response({"teacher" : user_serializer.data, "subjects" : subject_serializer.data})
    
    def patch(self, request, pk, format = None):
        permission_classes = [IsAuthenticated]
        try:
            user = models.UserAccount.objects.get(email = request.user)
        except models.UserAccount.DoesNotExist or user.type != models.UserAccount.Types.SCHOOL_ADMIN:
            return Response({"error" :"Usuario Invalido"})
        teacher = models.Teacher.objects.filter(id = pk).first()
        teacher_serializer = serializers.TeacherSerializer(teacher, data = request.data, partial = True)
        if teacher_serializer.is_valid():
            teacher_serializer.save()
            return Response({'teachers' : teacher_serializer.data})
        else:
            return Response(teacher_serializer.errors)
        
    def delete(self, request, pk, format = None):
        permission_classes = [IsAuthenticated]
        try:
            user = models.UserAccount.objects.get(email = request.user)
        except models.UserAccount.DoesNotExist or user.type != models.UserAccount.Types.SCHOOL_ADMIN:
            return Response({"error" :"Usuario Invalido"})
        teacher = models.Teacher.objects.filter(id = pk).first()
        teacher.delete()
        return Response({'message' : 'Profesor eliminado'})

        
class LevelsAndGradesApiView(APIView):
    def get(self, request, format = None):
        levels = models.Level.objects.all()
        levels_serializer = serializers.LevelSerializer(levels, many = True)
        grades = models.Grade.objects.all()
        grades_serializer = serializers.GradeWithLevelSerializer(grades, many = True)
        return Response({'levels' : levels_serializer.data, 'grades'  : grades_serializer.data})

    def post(self, request, format = None):
        permission_classes = [IsAuthenticated]
        try:
            user = models.UserAccount.objects.get(email = request.user)
        except models.UserAccount.DoesNotExist or user.type != models.UserAccount.Types.SCHOOL_ADMIN:
            return Response({"error" :"Usuario Invalido"})
        level_serializer = serializers.LevelSerializer(data = request.data.get('level'))
        if not level_serializer.is_valid():
            return Response(level_serializer.errors)
        level_serializer.save()
        grades_array = []
        for grade in request.data.get('grades'):
            grade['id_level'] = level_serializer.data.get('id')
            grade_serializer = serializers.GradeSerializer(data = grade)
            if not grade_serializer.is_valid():
                return Response(level_serializer.errors)
            grade_serializer.save()
            grades_array += grade_serializer.data
        return Response({'level' : level_serializer.data, 'grades' : grades_array})


    def patch(self, request, pk, format = None):
        permission_classes = [IsAuthenticated]
        try:
            user = models.UserAccount.objects.get(email = request.user)
        except models.UserAccount.DoesNotExist or user.type != models.UserAccount.Types.SCHOOL_ADMIN:
            return Response({"error" :"Usuario Invalido"})
        level_serializer = serializers.LevelSerializer(data = request.data.get('level'))
        if not level_serializer.is_valid():
            return Response(level_serializer.errors)
        for grade in request.data.get('grades'):
            grade_serializer = serializers.GradeSerializer(data = grade)
            if not grade_serializer.is_valid():
                return Response(grade_serializer.errors)
            grade_serializer.save()

        for grade in request.data.get('deleted_grades'):
            grade = models.Grade.objects.filter(letter = grade['letter'], id_level = pk).first()
            grade.delete()
        return Response({'message' : 'letras eliminadas'})

    def delete(self, request, pk, format = None):
        permission_classes = [IsAuthenticated]
        try:
            user = models.UserAccount.objects.get(email = request.user)
        except models.UserAccount.DoesNotExist or user.type != models.UserAccount.Types.SCHOOL_ADMIN:
            return Response({"error" :"Usuario Invalido"})
        level = models.Level.objects.filter(id = pk).first()
        level.delete()
        return Response({'message' : 'cursos y letras eliminadas'})


class SubjectApiView(APIView):
    def post(self, request, format = None):
        permission_classes = [IsAuthenticated]
        try:
            user = models.UserAccount.objects.get(email = request.user)
        except models.UserAccount.DoesNotExist or user.type != models.UserAccount.Types.SCHOOL_ADMIN:
            return Response({"error" :"Usuario Invalido"})
        subject_serializer = serializers.SubjectSerializer(data = request.data)
        if not subject_serializer.is_valid():
            return Response(subject_serializer.errors)
        subject_serializer.save()
        return Response({'subject' : subject_serializer.data})

    def patch(self, request, pk, format = None):
        permission_classes = [IsAuthenticated]
        try:
            user = models.UserAccount.objects.get(email = request.user)
        except models.UserAccount.DoesNotExist or user.type != models.UserAccount.Types.SCHOOL_ADMIN:
            return Response({"error" :"Usuario Invalido"})
        subject = models.Subject.objects.filter(id = pk).first()
        subject_serializer = serializers.SubjectSerializer(subject, data = request.data, partial = True)
        if not subject_serializer.is_valid():
            return Response(subject_serializer.errors)
        subject_serializer.save()
        return Response({'subject' : subject_serializer.data})
    
    def delete(self, request, pk, format = None):
        permission_classes = [IsAuthenticated]
        try:
            user = models.UserAccount.objects.get(email = request.user)
        except models.UserAccount.DoesNotExist or user.type != models.UserAccount.Types.SCHOOL_ADMIN:
            return Response({"error" :"Usuario Invalido"})
        subject = models.Subject.objects.filter(id = pk).first()
        subject.delete()
        return Response({'message' : 'Asignatura eliminada'})


class ProfileSchoolManager(APIView):
    def get(self, request, format = None):
        permission_classes = [IsAuthenticated]
        user = models.UserAccount.objects.get(email = request.user)
        if user.type != models.UserAccount.Types.SCHOOL_ADMIN:
            pass
        user_serializer = serializers.SchoolAdminNameSerializer(user)
        teachers = models.Teacher.objects.all()
        teachers_serializer = serializers.TeacherNameSerializer(teachers, many = True)
        students = models.Student.objects.all()
        students_serializer = serializers.StudentNameSerializer(students, many = True)
        levels = models.Level.objects.all()
        levels_serializer = serializers.LevelSerializer(levels, many = True)
        grades = models.Grade.objects.all()
        grades_serializer = serializers.GradeWithLevelSerializer(grades, many = True)
        subject = models.Subject.objects.all()
        subject_serializer = serializers.SubjectWithTeacherSerializer(subject, many = True)
        return Response({"school_admin" : user_serializer.data, "teachers" : teachers_serializer.data, "students" : students_serializer.data, "levels" : levels_serializer.data, "grades" : grades_serializer.data, "subjects" : subject_serializer.data})