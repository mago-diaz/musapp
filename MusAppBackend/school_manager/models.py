from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager

class Level(models.Model):
    class Types(models.TextChoices):
        BASICO  = "BASICO", "basico"
        MEDIO = "MEDIO", "medio"
    class NumberTypes(models.TextChoices):
        PRIMERO = "PRIMERO", "primero"
        SEGUNDO = "SEGUNDO", "segundo"
        TERCERO = "TERCERO", "tercero"
        CUARTO = "CUARTO", "cuarto"
        QUINTO = "QUINTO", "quinto"
        SEXTO = "SEXTO", "sexto"
        SEPTIMO = "SEPTIMO", "septimo"
        OCTAVO = "OCTAVO", "octavo"
    number = models.CharField(max_length = 8, choices = NumberTypes.choices, default = NumberTypes.PRIMERO)
    type = models.CharField(max_length = 7, choices = Types.choices, default = Types.BASICO)

    def save(self, *args, **kwargs):
        self.isMedia()
        return super().save(*args, **kwargs)
    
    def isMedia(self):
        if self.number == self.NumberTypes.QUINTO or self.number == self.NumberTypes.SEXTO or self.number == self.NumberTypes.SEPTIMO or self.number == self.NumberTypes.OCTAVO:
            self.type = self.Types.BASICO


class Grade(models.Model):
    id_level = models.ForeignKey(Level, on_delete = models.CASCADE)  
    letter = models.CharField(max_length = 1)


class UserAccountManager(BaseUserManager):
    def create_user(self, email, first_name, last_name, password = None):
        if not email or len(email) <= 0:
            raise ValueError("Email field is required")
        if not password:
            raise ValueError("Password is must")
    
        user = self.model(
            email = self.normalize_email(email),
            first_name = first_name,
            last_name = last_name,
        )

        user.set_password(password)
        user.save(using = self._db)
        return user

    def create_superuser(self, email, first_name, last_name, password):
        user = self.create_user(
            email = self.normalize_email(email),
            first_name = first_name,
            last_name = last_name,
            password= password,
        )
        user.is_admin = True
        user.is_staff = True
        user.is_superuser = True
        user.type = UserAccount.Types.SCHOOL_ADMIN
        user.save(using = self._db)
        return user


class UserAccount(AbstractBaseUser):
    class Types(models.TextChoices):
        STUDENT  = "STUDENT", "student"
        TEACHER = "TEACHER", "teacher"
        SCHOOL_ADMIN = "SCHOOL_ADMIN", "school_admin"

    type = models.CharField(max_length = 12, choices = Types.choices, default = Types.STUDENT)
    email = models.EmailField(max_length = 255, unique = True)
    first_name = models.CharField(max_length = 255)
    middle_name = models.CharField(max_length = 255, blank = True)
    last_name  = models.CharField(max_length = 255)
    mothers_maiden_name = models.CharField(max_length = 255, blank = True)
    grade_id = models.ForeignKey(Grade, on_delete = models.CASCADE, blank = True, null = True)
    
    is_active = models.BooleanField(default = True)
    is_admin = models.BooleanField(default = False)
    is_staff = models.BooleanField(default = False)
    is_superuser = models.BooleanField(default = False)
    

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['first_name', 'last_name']

    is_student = models.BooleanField(default = False)
    is_teacher = models.BooleanField(default = False)

    objects = UserAccountManager()

    def __str__(self):
        return str(self.email)
      
    def has_perm(self , perm, obj = None):
        return self.is_admin
      
    def has_module_perms(self , app_label):
        return True

    def save(self, *args, **kwargs):
        if not self.type or self.type == None :
            self.type = UserAccount.Types.TEACHER
        return super().save(*args, **kwargs)


class StudentManager(models.Manager):
    def create_user(self, email, first_name, last_name, password = None):
        if not email or len(email) <= 0:
            raise ValueError("Email field is required")
        if not password:
            raise ValueError("Password is must")
        email = email.lower()
        user = self.model(
            email  = email,
            first_name = first_name,
            last_name = last_name
        )
        user.set_password(password)
        user.save(using = self._db)
        return user

    def get_queryset(self, *args, **kwargs):
        queryset = super().get_queryset(*args , **kwargs)
        queryset = queryset.filter(type = UserAccount.Types.STUDENT)
        return queryset
    

class Student(UserAccount):
    class Meta:
        proxy = True
    objects = StudentManager()

    def save(self , *args , **kwargs):
        self.type = UserAccount.Types.STUDENT
        self.is_student = True
        return super().save(*args , **kwargs)



class TeacherManager(models.Manager):
    def create_user(self, email, first_name, last_name, password = None):
        if not email or len(email) <= 0:
            raise ValueError("Email field is required")
        if not password:
            raise ValueError("Password is must")
        email = email.lower()
        user = self.model(
            email  = email,
            first_name = first_name,
            last_name = last_name
        )
        user.set_password(password)
        user.save(using = self._db)
        return user

    def get_queryset(self, *args, **kwargs):
        queryset = super().get_queryset(*args , **kwargs)
        queryset = queryset.filter(type = UserAccount.Types.TEACHER)
        return queryset


class Teacher(UserAccount):
    class Meta :
        proxy = True
    objects = TeacherManager()

    def save(self  , *args , **kwargs):
        self.type = UserAccount.Types.TEACHER
        self.is_teacher = True
        return super().save(*args , **kwargs)



class AdminManager(models.Manager):
    def create_user(self, email, first_name, last_name, password = None):
        if not email or len(email) <= 0:
            raise ValueError("Email field is required")
        if not password:
            raise ValueError("Password is must")
        email = email.lower()
        user = self.model(
            email  = email,
            first_name = first_name,
            last_name = last_name
        )
        user.set_password(password)
        user.save(using = self._db)
        return user

    def get_queryset(self, *args, **kwargs):
        queryset = super().get_queryset(*args , **kwargs)
        queryset = queryset.filter(type = UserAccount.Types.SCHOOL_ADMIN)
        return queryset


class Admin(UserAccount):
    class Meta :
        proxy = True
    objects = AdminManager()

    def save(self  , *args , **kwargs):
        self.type = UserAccount.Types.SCHOOL_ADMIN
        self.is_teacher = True
        return super().save(*args , **kwargs)


class Subject(models.Model):
    name = models.CharField(max_length = 255)
    description = models.TextField(blank=True)
    teacher_id = models.ForeignKey(Teacher, on_delete = models.CASCADE, related_name = 'teacher')
    grade_id = models.ForeignKey(Grade, on_delete= models.CASCADE)
    students = models.ManyToManyField(Student, related_name  ='students')
