from django.contrib import admin
from .models import User, Department, Designation, Announcement, Attendance, Expense, Leave, Notification, Project, Task, Setting

# Register your models here.

admin.site.register(User)
admin.site.register(Department)
admin.site.register(Designation)
admin.site.register(Announcement)
admin.site.register(Attendance)
admin.site.register(Expense)
admin.site.register(Leave)
admin.site.register(Notification)
admin.site.register(Project)
admin.site.register(Task)
admin.site.register(Setting)
