# API Specifications

This directory is the single source of truth for all API specifications in the AI Event Concepter project.

## API-First Approach

We follow an API-first approach to development:

1. **Design**: All API changes start with updating the OpenAPI specification
2. **Review**: API changes are reviewed by the team before implementation
3. **Generate**: Code is generated from the OpenAPI specs
4. **Implement**: Business logic is implemented using the generated code

## Directory Structure

```
/api
  ├── gateway.yaml         # API Gateway specification
  ├── user-service.yaml    # User Service specification
  ├── concept-service.yaml # Concept Service specification
  ├── genai-service.yaml   # GenAI Service specification
  ├── scripts/             # Code generation scripts
  └── README.md            # This file
```

## Usage

### Linting OpenAPI Specs

```bash
npm run lint:openapi
```

### Generating Code

```bash
./api/scripts/gen-all.sh
```

This will generate:
- Java controllers and models for Spring Boot services
- Python client for the GenAI service
- TypeScript SDK for the web client

## Versioning

All APIs are versioned in the URL path (e.g., `/api/v1/resource`). When making breaking changes:

1. Create a new version in the URL path
2. Update the OpenAPI spec to reflect the new version
3. Generate new code for the new version
4. Maintain backward compatibility for a reasonable period

## Best Practices

- Always run the linter before committing changes
- Keep the OpenAPI specs DRY by using components and references
- Document all endpoints, parameters, and responses
- Include examples for request and response bodies
- Use consistent naming conventions across all APIs
