from python:3.8

WORKDIR /home/apps
COPY . .
RUN apt update
RUN apt install librdkafka-dev build-assential awscli
RUN pip install -r requirements.txt

