from django.db import models
from django.contrib.auth.models import User

class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    phone_number = models.CharField(max_length=20, blank=True)
    goal = models.CharField(max_length=255, blank=True)
    joined = models.DateField(auto_now_add=True)

    def __str__(self):
        return self.user.username

class Trainer(models.Model):
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        null=True,    # бұрынғы жазбалар үшін бос болуына рұқсат
        blank=True,   # admin-да да бос қалуы мүмкін
    )
    name = models.CharField(max_length=100)
    contact_number = models.CharField(max_length=20)
    email = models.EmailField()
    image_url = models.URLField()
    available_days = models.JSONField()      # ["Monday","Wednesday",…]
    working_hours = models.JSONField()       # {"Monday":"9-17","Wednesday":"10-18",…}

    def __str__(self):
        return self.name

class Message(models.Model):
    user      = models.ForeignKey(User,    on_delete=models.CASCADE)   # кім жіберді
    trainer   = models.ForeignKey(Trainer, on_delete=models.CASCADE)   # кім қабылдайды
    content   = models.TextField()                                     # мәтін
    timestamp = models.DateTimeField(auto_now_add=True)                # қашан жіберілді

    def __str__(self):
        return f'{self.user.username} → {self.trainer.name}'

class UserGoal(models.Model):
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='goals')
    text = models.CharField(max_length=255)
    created = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'{self.profile.user.username}: {self.text}'
    
class WorkoutPlan(models.Model):
    trainer   = models.ForeignKey(Trainer, on_delete=models.CASCADE, related_name='plans')
    title     = models.CharField(max_length=255)
    details   = models.TextField()
    created   = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'{self.trainer.user.username}: {self.title}'