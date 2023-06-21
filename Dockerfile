FROM python:3.9-alpine3.13
LABEL maintainer="aquivaelmaintainer"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt 
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
# apk add --update --no-cache postgresql-client && - INSTALL POSTGRESQL-CLIENT PACKAGE INSIDE OUR IMAGE TO CONNECT PYSCOPG2 WITH POSTGRESQL
# apk add --update --no-cache --virtual .tmp-build-deps - SETS A VIRTUAL DEPENDENCY PACKAGE TO REMOVE THEM LATER ON  
# build-base postgresql-dev musl-dev && - INSTALL THOSE PACKAGES
# apk del .tmp-build-deps = DELETE THOSE PACKAGES
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \ 
    apk add --update --no-cache --virtual .tmp-build-deps \ 
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin:$PATH"

USER django-user