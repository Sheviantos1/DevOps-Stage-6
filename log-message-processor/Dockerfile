FROM python:3.9-slim

# Install build tools
RUN apt-get update && apt-get install -y gcc

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
CMD ["python", "main.py"]