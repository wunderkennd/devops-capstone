FROM tiangolo/uvicorn-gunicorn-fastapi:python3.7
LABEL maintainer Wunderkennd <klsylvainiii@gmail.com>
RUN alias pip=pip3

RUN sudo apt install pipenv
COPY ./app /app
COPY ./titan /titan

EXPOSE 80 443

# To better understand the CMD see the following below:
# 1) main: the file main.py (the Python "module").
# 2) app: the object created inside of main.py with the line app = FastAPI().
# 3) --reload: make the server restart after code changes. Only do this for development.
CMD uvicorn main:app --reload