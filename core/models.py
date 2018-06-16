from django.db import models
from django.contrib.auth.base_user import AbstractBaseUser
from django.contrib.auth.models import PermissionsMixin, UserManager
import uuid
from django.utils import timezone
from django.conf import settings
from django.utils.crypto import get_random_string


class GenericBaseClass(models.Model):

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    updated_at = models.DateTimeField(auto_now=True, null=True)
    created_at = models.DateTimeField(db_index=True, default=timezone.now)
    is_deleted = models.BooleanField(default=False)

    class Meta:
        abstract = True
        get_latest_by = "created_at"


class User(AbstractBaseUser, GenericBaseClass, PermissionsMixin):
    objects = UserManager()
    REQUIRED_FIELDS = ['password']

    USERNAME_FIELD = 'username'
    USER_ROLE_CHOICES = (
        ('professional', 'Professional'),
        ('patient', 'Patient')
    )

    username = models.CharField(max_length=20, unique=True)
    role = models.CharField(choices=USER_ROLE_CHOICES, default='patient', max_length=20)
    language = models.CharField(max_length=50, default='English', null=False)

    def is_professional(self):
        return self.role == 'professional'

    def is_patient(self):
        return self.role == 'patient'

    def get_full_name(self):
        return self.username

    def get_short_name(self):
        return self.username


class Conversation(GenericBaseClass):
    STATUS_OPTIONS = (
        ('pending', 'Pending'),
        ('closed', 'Closed'),
        ('cancelled', 'Cancelled'),
        ('active', 'Active'),
        ('suspended', 'Suspended'),
    )
    # Professional|Patient value can be NULL because initially conversation is started by one party
    professional = models.ForeignKey(settings.AUTH_USER_MODEL, related_name='professional', null=True)
    patient = models.ForeignKey(settings.AUTH_USER_MODEL, related_name='patient', null=True)
    professional_penname = models.CharField(max_length=20,
                                            default=get_random_string,
                                            null=False)
    patient_penname = models.CharField(max_length=20,
                                       default=get_random_string,
                                       null=False)

    title = models.CharField(max_length=300, null=False, blank=True)
    tags = models.CharField(max_length=500, null=False, blank=True)
    is_patient_anonymous = models.BooleanField(default=True, null=False)
    status = models.CharField(choices=STATUS_OPTIONS, max_length=20, default='pending')


    def activate(self):
        self.status = 'active'
        self.save()

    def suspend(self):
        self.status = 'suspended'
        self.save()

    def cancel(self):
        self.status = 'cancelled'
        self.save()

    def close(self):
        self.status = 'closed'
        self.save()


class Message(GenericBaseClass):
    MESSAGE_STATUS_CHOICES = (
        ('active', 'Active'),
        ('suspended', 'Suspended'),
    )

    conversation = models.ForeignKey(Conversation)
    user = models.ForeignKey(settings.AUTH_USER_MODEL)
    text = models.TextField(null=False, blank=True)
    status = models.CharField(choices=MESSAGE_STATUS_CHOICES, default='active', null=False, max_length=30)

