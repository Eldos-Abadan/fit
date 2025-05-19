from django.urls import path
from rest_framework.routers import DefaultRouter
from .views import (
    RegisterView, LoginView, ProfileRetrieveUpdateView,
    TrainerListView, TrainerDetailView,
    MessageListCreateView, TrainerViewSet,
    UserGoalListCreateView, UserGoalDeleteView,
    WorkoutPlanViewSet
)

router = DefaultRouter()
router.register('trainers', TrainerViewSet, basename='trainer')

urlpatterns = [
    path('auth/register/', RegisterView.as_view(), name='auth-register'),
    path('auth/login/',    LoginView.as_view(),    name='auth-login'),
    path('profile/',       ProfileRetrieveUpdateView.as_view(), name='profile-detail'),

    path('trainers/',           TrainerListView.as_view(),      name='trainer-list'),
    path('trainers/<int:id>/',  TrainerDetailView.as_view(),    name='trainer-detail'),
    path('trainers/<int:trainer_id>/chat/', MessageListCreateView.as_view(), name='trainer-chat'),

    path('profile/goals/',        UserGoalListCreateView.as_view(),  name='goal-list-create'),
    path('profile/goals/<int:pk>/', UserGoalDeleteView.as_view(),     name='goal-delete'),
] + router.urls

router = DefaultRouter()
router.register('workouts', WorkoutPlanViewSet, basename='workoutplan')

urlpatterns += router.urls
