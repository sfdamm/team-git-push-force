#!/bin/bash

# AI Event Concepter - Documentation Launcher
echo "🚀 AI Event Concepter - Starting API Documentation"
echo "=================================================="

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose >/dev/null 2>&1; then
    echo "❌ docker-compose not found. Please install Docker Compose."
    exit 1
fi

echo "📚 Starting Swagger UI documentation for all services..."

# Start all documentation containers
docker-compose -f docker-compose.swagger.yml up -d

# Wait a moment for containers to start
sleep 3

echo ""
echo "✅ Documentation services are starting up!"
echo ""
echo "📖 Access your API documentation:"
echo "=================================="
echo "🏠 Documentation Hub:     http://localhost:8094"
echo "🚪 API Gateway:           http://localhost:8090"
echo "👥 User Service:          http://localhost:8091"
echo "💡 Concept Service:       http://localhost:8092"
echo "🧠 GenAI Service:         http://localhost:8093"
echo ""
echo "🔍 Spring Boot Integration (if running):"
echo "========================================"
echo "📊 API Gateway Swagger:   http://localhost:8080/swagger-ui.html"
echo "📊 API Gateway JSON:      http://localhost:8080/v3/api-docs"
echo "❤️  Health Check:         http://localhost:8080/health"
echo ""
echo "🛠 Useful Commands:"
echo "=================="
echo "🔧 Stop all docs:         docker-compose -f docker-compose.swagger.yml down"
echo "📋 View logs:             docker-compose -f docker-compose.swagger.yml logs -f"
echo "🔄 Restart docs:          docker-compose -f docker-compose.swagger.yml restart"
echo ""
echo "🎯 Quick Start Spring Boot API Gateway:"
echo "======================================="
echo "cd server && ./gradlew bootRun"
echo ""

# Check if containers started successfully
echo "🔍 Checking container status..."
docker-compose -f docker-compose.swagger.yml ps

echo ""
echo "🎉 Documentation setup complete!"
echo "Visit http://localhost:8094 to get started!" 