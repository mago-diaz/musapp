from django.urls import path, include

from school_manager import views

urlpatterns = [
    path('login/', views.LoginApiView.as_view()),
    path('logout/', views.LogoutApiView.as_view()),
    path('create-user/', views.CreateUserApiView.as_view()),
    path('student-profile/', views.ProfileStudentApiView.as_view()),
    path('student-profile/<int:pk>/', views.ProfileStudentApiView.as_view()),
    path('teacher-profile/', views.ProfileTeacherApiView.as_view()),
    path('teacher-profile/<int:pk>/', views.ProfileTeacherApiView.as_view()),
    path("school-manager-profile/", views.ProfileSchoolManager.as_view()),
    path("levels-and-grades/", views.LevelsAndGradesApiView.as_view()),
    path("levels-and-grades/<int:pk>/", views.LevelsAndGradesApiView.as_view()),
    path("subjects/", views.SubjectApiView.as_view()),
    path("subjects/<int:pk>/", views.SubjectApiView.as_view()),
]