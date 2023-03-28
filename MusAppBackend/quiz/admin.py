from django.contrib import admin

from quiz import models
# Register your models here.

admin.site.register(models.Quiz)
admin.site.register(models.TOFQuestion)
admin.site.register(models.SelectionQuestion)
admin.site.register(models.WrittingQuestion)
admin.site.register(models.PianoQuestion)
admin.site.register(models.MusicSheetQuestion)

admin.site.register(models.AnsweredQuiz)
admin.site.register(models.AnsweredTOFQuestion)
admin.site.register(models.AnsweredSelectionQuestion)
admin.site.register(models.AnsweredWrittingQuestion)
admin.site.register(models.AnsweredPianoQuestion)
admin.site.register(models.AnsweredMusicSheetQuestion)
