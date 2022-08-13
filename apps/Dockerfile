from python:3.10

WORKDIR /home/apps
COPY . .
RUN apt-get update
RUN apt-get install librdkafka-dev awscli -y
RUN pip install -r requirements.txt