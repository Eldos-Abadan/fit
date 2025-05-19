# backend/api/serializers.py

from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Profile, Trainer, Message, UserGoal, WorkoutPlan


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'first_name', 'last_name', 'email']


class RegisterSerializer(serializers.ModelSerializer):
    phone_number = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = [
            'username',
            'first_name',
            'last_name',
            'email',
            'password',
            'phone_number',
        ]
        extra_kwargs = {
            'password': {'write_only': True},
        }

    def create(self, validated_data):
        phone = validated_data.pop('phone_number')
        password = validated_data.pop('password')
        user = User.objects.create_user(**validated_data)
        user.set_password(password)
        user.save()
        # Профиль жасау
        Profile.objects.create(user=user, phone_number=phone)
        return user


class ProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = Profile
        fields = ['user', 'phone_number', 'goal', 'joined']
        read_only_fields = ['joined']


class TrainerSerializer(serializers.ModelSerializer):
    user = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = Trainer
        fields = [
            'id',
            'user',            # <-- міне осында
            'name',
            'contact_number',
            'email',
            'image_url',
            'available_days',
            'working_hours',
        ]


class MessageSerializer(serializers.ModelSerializer):
    user_id = serializers.IntegerField(source='user.id', read_only=True)
    user_name = serializers.CharField(source='user.username', read_only=True)
    trainer_id = serializers.IntegerField(source='trainer.id', read_only=True)

    class Meta:
        model = Message
        fields = ['id', 'user_id', 'user_name', 'trainer_id', 'content', 'timestamp']


class UserGoalSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserGoal
        fields = ['id', 'text', 'created']
        read_only_fields = ['id', 'created']

class WorkoutPlanSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkoutPlan
        fields = ['id', 'title', 'details', 'created']
        read_only_fields = ['id', 'created']