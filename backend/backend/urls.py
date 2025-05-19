from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from back import views, auth  # Файл атаулары мен модуль құрылымын өзіңізге сәйкес өзгертіңіз
from django.http import HttpResponse

router = DefaultRouter()
router.register(r'user', views.UserViewSet, basename='user')
router.register(r'departments', views.DepartmentViewSet, basename='department')
router.register(r'designations', views.DesignationViewSet, basename='designation')
router.register(r'projects', views.ProjectViewSet, basename='project')
router.register(r'tasks', views.TaskViewSet, basename='task')
router.register(r'announcements', views.AnnouncementViewSet, basename='announcement')
router.register(r'attendance', views.AttendanceViewSet, basename='attendance')
router.register(r'expenses', views.ExpenseViewSet, basename='expense')
router.register(r'leaves', views.LeaveViewSet, basename='leave')
router.register(r'notifications', views.NotificationViewSet, basename='notification')
router.register(r'settings', views.SettingViewSet, basename='setting')

def home(request):
    return HttpResponse("Welcome to the Homepage!")

urlpatterns = [
    path('', home, name='home'),
    path('admin/', admin.site.urls),
    path('api/login/', auth.login_view, name='api_login'),
    path('api/refresh_token/', auth.refresh_token, name='api_refresh_token'),
    path('api/initial/', views.initial, name='api_initial'),
    path('api/', include(router.urls)),
    path('api-auth/', include('rest_framework.urls')),
]

