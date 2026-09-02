#!/bin/bash
set -e

mkdir -p /app/db /app/media

echo "==> Running migrations..."
python manage.py migrate --noinput

if [ -n "$DJANGO_SUPERUSER_PHONE" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then
    python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(phone='$DJANGO_SUPERUSER_PHONE').exists():
    User.objects.create_superuser(
        phone='$DJANGO_SUPERUSER_PHONE',
        full_name='$DJANGO_SUPERUSER_NAME',
        password='$DJANGO_SUPERUSER_PASSWORD',
        is_active=True,
    )
    print('Superuser created.')
else:
    print('Superuser already exists.')
"
fi

echo "==> Collecting static files..."
python manage.py collectstatic --noinput 2>/dev/null || true

echo "==> Starting application..."
exec "$@"