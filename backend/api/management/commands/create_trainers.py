# backend/api/management/commands/create_trainers.py

from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from api.models import Profile, Trainer

TRAINERS = [
    {
      'username': 'trainer1',
      'password': 'pass1234',
      'first_name': 'Alice',
      'last_name': 'Smith',
      'email': 'alice@example.com',
      'phone_number': '777111222',
      'name': 'Alice S.',
      'contact_number': '777111222',       # Trainer.contact_number
      'image_url': 'https://example.com/a.jpg',
      'available_days': ['Monday','Wednesday','Friday'],
      'working_hours': {'Monday':'9-17','Wednesday':'10-18','Friday':'8-12'},
    },
    # trainer2, trainer3 — ұқсас
]

class Command(BaseCommand):
    help = 'Create sample trainers'

    def handle(self, *args, **options):
        for data in TRAINERS:
            # 1) User
            user = User.objects.create_user(
                username=data['username'],
                password=data['password'],
                email=data['email'],
                first_name=data['first_name'],
                last_name=data['last_name'],
            )
            # 2) Profile (телефонды Profile-ға жазамыз)
            Profile.objects.create(
                user=user,
                phone_number=data['phone_number'],
            )
            # 3) Trainer
            Trainer.objects.create(
                user=user,
                name=data['name'],
                contact_number=data['contact_number'],
                email=data['email'],
                image_url=data['image_url'],
                available_days=data['available_days'],
                working_hours=data['working_hours'],
            )
            self.stdout.write(self.style.SUCCESS(f'Created {data["username"]}'))
