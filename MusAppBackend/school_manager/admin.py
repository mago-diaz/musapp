from django.contrib import admin
from school_manager import models

# Register your models here.
admin.site.register(models.Level)
admin.site.register(models.Grade)
admin.site.register(models.UserAccount)
admin.site.register(models.Student)
admin.site.register(models.Teacher)
admin.site.register(models.Admin)
admin.site.register(models.Subject)