# Pull base image
FROM python:3.10.6-slim-buster as app
LABEL maintainer="{{cookiecutter.full_name}} <{{cookiecutter.email}}>"

WORKDIR /app/backend

# Install dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential curl libpq-dev gcc \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean \
  && useradd --create-home python


# Set environment variables
USER python
ARG DEBUG="false"
ENV DEBUG="${DEBUG}" \
  PYTHONUNBUFFERED="true" \
  PYTHONPATH="." \
  PATH="${PATH}:/home/python/.local/bin" \
  USER="python" \
  PYTHONDONTWRITEBYTECODE="true"

# Add the rest of the code
COPY . /app/backend
COPY ./scripts/ /app/

# Install python dependencies from poetry
RUN pip install poetry
RUN poetry config virtualenvs.create false
RUN poetry install


# Make port 8000 available for the app
ENV PORT 8000
EXPOSE 8000

# Change directory so that scripts could locate manage.py
WORKDIR /app/backend

# Be sure to use 0.0.0.0 for the host within the Docker container,
# otherwise the browser won't be able to find it
# RUN ["chmod", "+x", "./../entrypoint.sh"]
ENTRYPOINT ["sh", "../entrypoint.sh" ]