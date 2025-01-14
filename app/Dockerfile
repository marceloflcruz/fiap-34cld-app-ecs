FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt requirements.txt
COPY app.py .
RUN pip install -r requirements.txt

COPY . .

CMD ["python", "app.py"]
