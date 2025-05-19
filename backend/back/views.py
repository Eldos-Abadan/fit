from django.shortcuts import render
from rest_framework import viewsets, generics, status
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.http import JsonResponse
from .models import User, Department, Designation, Project, Task, Announcement, Attendance, Expense, Leave, Notification, Setting
from .serializers import (
    UserSerializer, DepartmentSerializer, DesignationSerializer,
    ProjectSerializer, TaskSerializer, AnnouncementSerializer,
    AttendanceSerializer, ExpenseSerializer, LeaveSerializer,
    NotificationSerializer, SettingSerializer
)

# User ViewSet for full CRUD on users
class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['role', 'department', 'designation', 'status']
    # Optionally, you can set permission_classes = [IsAuthenticated] globally in settings



# Department CRUD views
class DepartmentViewSet(viewsets.ModelViewSet):
    queryset = Department.objects.filter(deleted_at__isnull=True)
    serializer_class = DepartmentSerializer

class DesignationViewSet(viewsets.ModelViewSet):
    queryset = Designation.objects.filter(deleted_at__isnull=True)
    serializer_class = DesignationSerializer

class ProjectViewSet(viewsets.ModelViewSet):
    queryset = Project.objects.filter(deleted_at__isnull=True)
    serializer_class = ProjectSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['status']

    def perform_create(self, serializer):
        # Set current user as creator of the project
        serializer.save(created_by=self.request.user)

class TaskViewSet(viewsets.ModelViewSet):
    queryset = Task.objects.filter(deleted_at__isnull=True)
    serializer_class = TaskSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['user', 'project', 'status']

    def perform_create(self, serializer):
        # Set current user as creator/assigner of the task
        serializer.save(created_by=self.request.user)

class AnnouncementViewSet(viewsets.ModelViewSet):
    queryset = Announcement.objects.filter(deleted_at__isnull=True)
    serializer_class = AnnouncementSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['status']

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)

class AttendanceViewSet(viewsets.ModelViewSet):
    queryset = Attendance.objects.filter(deleted_at__isnull=True)
    serializer_class = AttendanceSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['user']

class ExpenseViewSet(viewsets.ModelViewSet):
    queryset = Expense.objects.filter(deleted_at__isnull=True)
    serializer_class = ExpenseSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['created_by', 'status']

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)

class LeaveViewSet(viewsets.ModelViewSet):
    queryset = Leave.objects.filter(deleted_at__isnull=True)
    serializer_class = LeaveSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['user', 'status', 'type']

class NotificationViewSet(viewsets.ModelViewSet):
    queryset = Notification.objects.filter(deleted_at__isnull=True)
    serializer_class = NotificationSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['user']

class SettingViewSet(viewsets.ModelViewSet):
    queryset = Setting.objects.all()
    serializer_class = SettingSerializer

# Initial setup endpoint: returns essential data for front-end initialization
def initial(request):
    # Ensure user is authenticated for initial data
    if not request.user or not request.user.is_authenticated:
        return JsonResponse({"detail": "Authentication credentials were not provided."}, status=401)
    user = request.user
    # Serialize current user info
    user_data = UserSerializer(user).data
    # List of departments and designations (for dropdowns, etc.)
    departments = DepartmentSerializer(Department.objects.filter(deleted_at__isnull=True), many=True).data
    designations = DesignationSerializer(Designation.objects.filter(deleted_at__isnull=True), many=True).data
    # Other initial data: e.g. settings (assuming one settings object)
    setting = Setting.objects.first()
    setting_data = SettingSerializer(setting).data if setting else None
    # Prepare response
    data = {
        "user": user_data,
        "departments": departments,
        "designations": designations,
        "settings": setting_data
    }
    return JsonResponse({"data": data}, status=200)

