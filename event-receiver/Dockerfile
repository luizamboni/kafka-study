FROM python:3.9

COPY . .
RUN pip install --upgrade pip
RUN pip install poetry==1.8.3
RUN poetry install

CMD ["poetry", "run", "flask", "run", "--host", "0.0.0.0"]