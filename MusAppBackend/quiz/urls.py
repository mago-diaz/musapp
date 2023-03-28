from django.urls import path, include

from quiz import views

urlpatterns = [
    path('teacher-quiz/', views.TeacherQuizApiView.as_view()),
    path('teacher-quiz/<int:pk>/', views.TeacherQuizApiView.as_view()),
    path('student-quiz/', views.StudentQuizApiView.as_view()),
    path('student-quiz/<int:pk>/', views.StudentQuizApiView.as_view()),
    path('student-answered-question/<int:pk>/', views.StudentAnsweredQuestionsApiView.as_view()),
    path('teacher-quiz-by-subject/',views.TeacherQuizzesBySubjectApiView.as_view()),
    path('teacher-quiz-by-subject/<int:pk>/',views.TeacherQuizzesBySubjectApiView.as_view()),
    path('student-quiz-by-subject/',views.StudentQuizzesBySubjectApiView.as_view()),
    path('student-quiz-by-subject/<int:pk>/',views.StudentQuizzesBySubjectApiView.as_view()),
    path('student-and-asnwers-by-quiz/<int:pk>/', views.StudentAndAnswersByQuizApiView.as_view()),
    path('check-answer-quiz-by-teacher/', views.CheckAnsweredQuizbyTeacherApiView.as_view()),
    path('check-answer-quiz-by-teacher/<int:pk>/', views.CheckAnsweredQuizbyTeacherApiView.as_view()),
]