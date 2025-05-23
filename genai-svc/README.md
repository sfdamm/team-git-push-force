# GenAI Service

A Flask-based microservice for document ingestion, RAG pipeline, and content creation using LangChain.

## Features

- Standard status page on the root route (/)
- LangChain integration for AI-powered content generation
- Containerized with Docker

## API Endpoints

### Status Endpoint

```
GET /
```

Returns the service status and information.

Example response:
```json
{
  "status": "healthy",
  "service": "GenAI Service",
  "version": "0.1.0",
  "description": "Document ingestion, RAG pipeline, and content creation service"
}
```

### LangChain Test Endpoint

```
GET /api/langchain-test
```

Tests the LangChain integration.

Example response:
```json
{
  "result": "This is a demonstration of LangChain integration.",
  "status": "success"
}
```

## Development

### Prerequisites

- Python 3.12
- Flask
- LangChain

### Setup

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Run the application:
   ```bash
   python app.py
   ```

The service will be available at http://localhost:5000.

## Docker

Build the Docker image:
```bash
docker build -t genai-svc .
```

Run the container:
```bash
docker run -p 8083:8083 genai-svc
```

## Docker Compose

The service is part of the larger AI Event Concepter application and can be started along with other services using Docker Compose:

```bash
docker-compose up
```