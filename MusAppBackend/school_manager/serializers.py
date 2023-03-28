from rest_framework import serializers
from school_manager import models

class UserAccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.UserAccount
        fields = ('email', 'password')
        ready_only_fields = ('email')

class LevelSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Level
        fields = '__all__'

class GradeWithLevelSerializer(serializers.ModelSerializer):
    id_level = LevelSerializer()
    class Meta:
        model = models.Grade
        fields = '__all__'

class GradeSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Grade
        fields = '__all__'

class StudentSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Student
        fields = '__all__'
    
    def create(self, validated_data):
        user = models.Student(**validated_data)
        user.set_password(validated_data['password'])
        user.save()
        return user

    def update(self, instance, validated_data):
        updated_user = super().update(instance, validated_data)
        if 'password' in validated_data:
            updated_user.set_password(validated_data['password'])
        updated_user.save()
        return updated_user


class TeacherSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Teacher
        fields = '__all__'
    
    def create(self, validated_data):
        user = models.Teacher(**validated_data)
        user.set_password(validated_data['password'])
        user.save()
        return user
    
    def update(self, instance, validated_data):
        updated_user = super().update(instance, validated_data)
        if 'password' in validated_data:
            updated_user.set_password(validated_data['password'])
        updated_user.save()
        return updated_user


class SubjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Subject
        fields = '__all__'


class TeacherNameSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Teacher
        fields = ['id', 'email', 'first_name', 'middle_name', 'last_name', 'mothers_maiden_name','type']


class StudentNameSerializer(serializers.ModelSerializer):
    grade_id = GradeWithLevelSerializer()
    class Meta:
        model = models.Student
        fields = ['id', 'email', 'first_name', 'middle_name', 'last_name', 'mothers_maiden_name', 'type', 'grade_id']


class SchoolAdminNameSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.UserAccount
        fields = ['id', 'email', 'first_name', 'middle_name', 'last_name', 'mothers_maiden_name']


class SubjectWithTeacherSerializer(serializers.ModelSerializer):
    grade_id = GradeWithLevelSerializer()
    teacher_id = TeacherNameSerializer()
    class Meta:
        model = models.Subject
        fields = '__all__'
