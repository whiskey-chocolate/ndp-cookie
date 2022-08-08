# Welcome to NDP 

You can use this repo as a template for a full stack dockerized web app, consisting of: 
- Next.js 
- Django Rest Frameork (DRF)
- Postgres

This project was inspired by the following repos:
- [cookiecutter-django](https://github.com/cookiecutter/cookiecutter-django)
- [docker-django-example](https://github.com/nickjj/docker-django-example)

The main difference for NDP is less customisation options but in favour of less code and simplicity. Additionally, the front end is a separate Next.js service communicating with backend DRF API via HTTPS.  

## Feature list
- Next.js
- DRF API
- Poetry python dependency management
- Postgres db
- JWT authentication on API via Firebase
- CORS enabled
- HTTPS enabled
- Postgres with UUID primary keys
- `run.sh` provides interface to manage DRF, poetry, heroku and vercel deployments

## Aim of this project

The aim of this project is to make it as quick and easy as possible to create a functioning full stack application to create products. Therefore, lots of the choices made are based on our current stack and workflow. However, we hope you find them sane choices. Any recommendations and advice is welcome. 

## Warning

The current project consists of a working project, think of this repo as the main example repo. Cookiecutter is used to create your own version from [ndp-cookie](https://github.com/whiskey-chocolate/ndp-cookie).

## Dependencies

1. Install [Docker](https://www.docker.com/)
2. Install [Cookiecutter](https://github.com/cookiecutter/cookiecutter). Recommend to do this in a virtualenv
```
# Create a virtual environment to isolate our cookiecutter locally
python3 -m venv env
source env/bin/activate  # On Windows use `env\Scripts\activate`

# Install cookiecutter into the virtual environment
pip install cookiecutter

# Set up a new ndp project 
cookiecutter https://github.com/whiskey-chocolate/ndp-cookie.git
```

## Installation 
1. `cookiecutter https://github.com/whiskey-chocolate/ndp-cookie.git`
2. Update local host for https
   1. `sudo chown -R {username} /private/etc/hosts` (updates ownership of hosts files)
   2. `chmod 755 /private/etc/hosts` (makes hosts file writable)
   3. Add `127.0.0.1       {project_slug}-api.local` to hosts file
3. Install local certificates
   1. `cd certs`
   2. `mkcert {project_slug}-api.local localhost 127.0.0.1 ::1`
   3. Rename certs to `domain.pem` and `domain-key.pem`
4. Update `.env` based on `.env.example`, adding Firebase credentials (see here [Google Firebase Docs](https://firebase.google.com/docs/admin/setup))
5. Run `docker-compose up --build -d` to start all services for development
6. Visit `localhost:3000` and you should be greeted with a welcome page for your project and if you wait a few seconds then you will see `{"message": "System up."} if the api and database have started up correctly
7. Visit `https://{project-slug}-api.local` to see the backend API

**Note: docker-compose is only used for development. Production builds should not use this config. This is because Heroku and Vercel have been chosen for managed deployment.**

## Notes
There are a number of decisions that have been made to make this stack as easy and quick to set up as possible. Features currently include:

- Nginx reverse proxy service set up to serve HTTPS locally
- CORS enabled across the frontend and backend services
- Custom User model in DRF with primary key of type UUID
- `.env.example` gives example of `.env` file structure
- Backend service relies on Firebase Authentication via JWT tokens


## Todo

- [ ] Push to Heroku
- [ ] Add Celery
- [ ] Add Sentry
- [ ] Add Travis
- [ ] Push to Vercel
