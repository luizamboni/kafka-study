FROM python:3.8

WORKDIR /home/apps
COPY . .
RUN apt-get update
RUN apt-get install librdkafka-dev awscli protobuf-compiler -y
RUN pip install -r requirements.txt