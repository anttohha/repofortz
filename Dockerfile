FROM python:3.10-slim
RUN mkdir /app
ADD . /app
WORKDIR /app
RUN apt update -y && apt-get install -y libpq-dev
RUN pip install Flask
CMD ["python", "app.py"]
