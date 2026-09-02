FROM python:3.11-slim-bullseye AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc \
        libjpeg62-turbo-dev \
        zlib1g-dev \
        libwebp-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


FROM python:3.11-slim-bullseye

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DJANGO_SETTINGS_MODULE=tecno_shop.settings

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
        libjpeg62-turbo \
        zlib1g \
        libwebp6 \
        curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /install /usr/local

COPY manage.py .
COPY requirements.txt .
COPY tecno_shop/     tecno_shop/
COPY Account/        Account/
COPY Product/        Product/
COPY home/           home/
COPY admin_persian/  admin_persian/
COPY templates/      templates/
COPY statics/        statics/
COPY media/          media/

COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

RUN mkdir -p /app/db /app/staticfiles /app/media/products
RUN python manage.py collectstatic --noinput 2>/dev/null || true

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

ENTRYPOINT ["/entrypoint.sh"]