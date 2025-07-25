FROM python:3.12.8-alpine3.20

LABEL maintainer="Pawel"
ENV PYTHONUNBUFFERED=1

COPY ./requirements.txt      /tmp/requirements.txt
COPY ./requirements.dev.txt  /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false

RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
    build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then \
    /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -f /tmp/requirements*.txt && \
    chmod 1777 /tmp && \
    apk del .tmp-build-deps && \
    adduser --disabled-password --home /home/django-user django-user

RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp /tmp/.X11-unix

ENV PATH="/py/bin:$PATH"
USER django-user