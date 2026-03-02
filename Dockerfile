FROM python:3.12-slim

WORKDIR /app/lambda

COPY lambda/ .

# Output CSVs land here — mount ./data at runtime
RUN mkdir -p /app/data

CMD ["python", "sync.py", "update"]
