from rest_framework import serializers
from .models import User, Department, Designation, Project, Task, Announcement, Attendance, Expense, Leave, Notification, Setting
from django.contrib.auth.hashers import make_password

class UserSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField(read_only=True)
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name', 'full_name',
            'role', 'status', 'last_active', 'department', 'designation',
            'phone', 'avatar', 'country', 'city', 'address', 'gender', 'birthday', 'description',
            'password',
        ]
        extra_kwargs = {
            'password': {'write_only': True},
            'username': {'required': False, 'allow_blank': True}  # allow creating user without username
        }

    def get_full_name(self, obj):
        # Combine first and last name
        name = f"{obj.first_name} {obj.last_name}".strip()
        return name if name else obj.username

    def create(self, validated_data):
        # Hash the password before saving
        if 'password' in validated_data:
            validated_data['password'] = make_password(validated_data['password'])
        return super().create(validated_data)

class DepartmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Department
        fields = '__all__'

class DesignationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Designation
        fields = '__all__'

class ProjectSerializer(serializers.ModelSerializer):
    created_by_name = serializers.SerializerMethodField(read_only=True)
    class Meta:
        model = Project
        fields = [
            'id', 'name', 'description', 'status', 'progress',
            'completed_at', 'deleted_at',
            'created_by', 'created_by_name',
            'created_at', 'updated_at'
        ]

    def get_created_by_name(self, obj):
        return obj.created_by.get_full_name() if obj.created_by else None

class TaskSerializer(serializers.ModelSerializer):
    user_name = serializers.SerializerMethodField(read_only=True)
    project_name = serializers.SerializerMethodField(read_only=True)
    created_by_name = serializers.SerializerMethodField(read_only=True)
    class Meta:
        model = Task
        fields = [
            'id', 'user', 'user_name', 'project', 'project_name',
            'title', 'description', 'due_date', 'status', 'progress', 'deleted_at',
            'created_by', 'created_by_name',
            'created_at', 'updated_at'
        ]

    def get_user_name(self, obj):
        return obj.user.get_full_name() if obj.user else None

    def get_project_name(self, obj):
        return obj.project.name if obj.project else None

    def get_created_by_name(self, obj):
        return obj.created_by.get_full_name() if obj.created_by else None

class AnnouncementSerializer(serializers.ModelSerializer):
    created_by_name = serializers.SerializerMethodField(read_only=True)
    class Meta:
        model = Announcement
        fields = [
            'id', 'title', 'content', 'start_date', 'end_date', 'status', 'deleted_at',
            'created_by', 'created_by_name',
            'created_at', 'updated_at'
        ]

    def get_created_by_name(self, obj):
        return obj.created_by.get_full_name() if obj.created_by else None

class AttendanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Attendance
        fields = '__all__'

class ExpenseSerializer(serializers.ModelSerializer):
    created_by_name = serializers.SerializerMethodField(read_only=True)
    class Meta:
        model = Expense
        fields = [
            'id', 'title', 'description', 'amount', 'date', 'status', 'deleted_at',
            'created_by', 'created_by_name',
            'created_at', 'updated_at'
        ]

    def get_created_by_name(self, obj):
        return obj.created_by.get_full_name() if obj.created_by else None

class LeaveSerializer(serializers.ModelSerializer):
    user_name = serializers.SerializerMethodField(read_only=True)
    class Meta:
        model = Leave
        fields = [
            'id', 'user', 'user_name', 'start', 'end_date', 'type',
            'title', 'description', 'status', 'deleted_at',
            'created_at', 'updated_at'
        ]

    def get_user_name(self, obj):
        return obj.user.get_full_name() if obj.user else None

class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = '__all__'

class SettingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Setting
        fields = '__all__'
