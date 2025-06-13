#!/bin/bash

# AI Event Concepter - Documentation Stopper
echo "🛑 AI Event Concepter - Stopping API Documentation"
echo "=================================================="

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Cannot stop containers."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose >/dev/null 2>&1; then
    echo "❌ docker-compose not found. Please install Docker Compose."
    exit 1
fi

echo "📚 Stopping Swagger UI documentation containers..."

# Stop and remove all documentation containers
docker-compose -f docker-compose.swagger.yml down

echo ""
echo "✅ Documentation services stopped!"
echo ""
echo "🧹 Cleanup Options:"
echo "=================="
echo "🗑️  Remove volumes:       docker-compose -f docker-compose.swagger.yml down -v"
echo "🧽 Remove images:         docker-compose -f docker-compose.swagger.yml down --rmi all"
echo "💥 Full cleanup:          docker-compose -f docker-compose.swagger.yml down -v --rmi all --remove-orphans"
echo ""
echo "🔄 To restart documentation:"
echo "============================"
echo "💫 Run start script:      ./start-docs.sh"
echo ""

# Check final container status
echo "🔍 Checking remaining containers..."
RUNNING_CONTAINERS=$(docker-compose -f docker-compose.swagger.yml ps -q)

if [ -z "$RUNNING_CONTAINERS" ]; then
    echo "✅ All documentation containers stopped successfully!"
else
    echo "⚠️  Some containers may still be running:"
    docker-compose -f docker-compose.swagger.yml ps
fi

echo ""
echo "🎉 Documentation services shutdown complete!" 