FROM python:3.9

COPY . .

RUN pip install poetry
RUN poetry install

CMD ["poetry", "run", "flask", "run", "--host", "0.0.0.0"]