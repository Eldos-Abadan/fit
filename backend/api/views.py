# backend/api/views.py

from django.contrib.auth.models import User        # <- Міне мұнда
from rest_framework import generics, permissions, viewsets
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework.response import Response
from rest_framework.decorators import action

from .models import Profile, Trainer, Message, UserGoal, WorkoutPlan
from .serializers import (
    RegisterSerializer,
    ProfileSerializer,
    TrainerSerializer,
    MessageSerializer,
    UserGoalSerializer,
    WorkoutPlanSerializer
)


class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]


class LoginView(TokenObtainPairView):
    # Стандартты JWT логин view (refresh + access береді)
    # Қажет болса override етіп, user мәліметін қосуға болады
    pass


class ProfileRetrieveUpdateView(generics.RetrieveUpdateAPIView):
    serializer_class = ProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        # Профиль жоқ болса, жасаймыз
        profile, _ = Profile.objects.get_or_create(user=self.request.user)
        return profile


class TrainerListView(generics.ListAPIView):
    queryset = Trainer.objects.all()
    serializer_class = TrainerSerializer
    permission_classes = [permissions.IsAuthenticated]


class TrainerDetailView(generics.RetrieveAPIView):
    queryset = Trainer.objects.all()
    serializer_class = TrainerSerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'id'


class MessageListCreateView(generics.ListCreateAPIView):
    serializer_class = MessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        trainer_id = self.kwargs['trainer_id']
        return Message.objects.filter(
            user=self.request.user,
            trainer_id=trainer_id
        ).order_by('timestamp')

    def perform_create(self, serializer):
        trainer_id = self.kwargs['trainer_id']
        serializer.save(user=self.request.user, trainer_id=trainer_id)


class UserGoalListCreateView(generics.ListCreateAPIView):
    serializer_class = UserGoalSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return UserGoal.objects.filter(
            profile__user=self.request.user
        ).order_by('-created')

    def perform_create(self, serializer):
        profile, _ = Profile.objects.get_or_create(user=self.request.user)
        serializer.save(profile=profile)


class UserGoalDeleteView(generics.DestroyAPIView):
    serializer_class = UserGoalSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return UserGoal.objects.filter(profile__user=self.request.user)
    

class ChatView(generics.ListCreateAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = MessageSerializer

    def get_queryset(self):
        return Message.objects.filter(trainer__id=self.kwargs['trainer_id'])
    
    def perform_create(self, serializer):
        serializer.save(
            user=self.request.user,
            trainer_id=self.kwargs['trainer_id']
        )


class TrainerViewSet(viewsets.ReadOnlyModelViewSet):
    """
    /api/trainers/       → list all trainers
    /api/trainers/{pk}/   → retrieve one trainer
    """
    queryset = Trainer.objects.all()
    serializer_class = TrainerSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['get', 'post'], url_path='chat')
    def chat(self, request, pk=None):
        """
        GET  /api/trainers/{pk}/chat/ → list messages for this trainer
        POST /api/trainers/{pk}/chat/ → create a new message
        """
        # GET
        if request.method == 'GET':
            qs = Message.objects.filter(trainer_id=pk).order_by('timestamp')
            ser = MessageSerializer(qs, many=True)
            return Response(ser.data)

        # POST
        ser = MessageSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        ser.save(user=request.user, trainer_id=pk)
        return Response(ser.data, status=201)
    
class WorkoutPlanViewSet(viewsets.ModelViewSet):
    serializer_class = WorkoutPlanSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Тек өз жаттықтырушыңыздың жоспарлары
        trainer = Trainer.objects.filter(user=self.request.user).first()
        return WorkoutPlan.objects.filter(trainer=trainer)

    def perform_create(self, serializer):
        trainer = Trainer.objects.get(user=self.request.user)
        serializer.save(trainer=trainer)