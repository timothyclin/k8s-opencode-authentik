# Authentik PostgreSQL and Redis Deployment Design

## Overview

Add PostgreSQL and Redis deployments to the Authentik Helm chart to make it a complete, self-contained solution that deploys all required components.

## Requirements

- Deploy PostgreSQL and Redis as StatefulSets with persistent volumes
- Use existing configuration values for images, resources, and persistence
- Conditional deployment based on `postgres.enabled` and `redis.enabled` flags
- Maintain compatibility with existing Authentik configuration

## Architecture

The chart will deploy PostgreSQL and Redis alongside Authentik in a complete stack. Each component gets its own StatefulSet for stable network identity and PVC for data persistence.

## Components

### PostgreSQL Deployment
- **StatefulSet**: `charts/authentik/templates/postgres-statefulset.yaml`
- **Service**: `charts/authentik/templates/postgres-service.yaml`
- **PVC**: Conditional persistent volume claim
- **Config**: Uses postgres user/password from secrets

### Redis Deployment
- **StatefulSet**: `charts/authentik/templates/redis-statefulset.yaml`
- **Service**: `charts/authentik/templates/redis-service.yaml`
- **Config**: Password authentication from secrets

### Updated Configuration
- Secrets already include postgres and redis passwords
- ConfigMap references the deployed service names

## Data Flow

1. Chart deploys PostgreSQL StatefulSet with PVC
2. Chart deploys Redis StatefulSet
3. Authentik deployment connects to postgres and redis services
4. Data persists across pod restarts via PVCs

## Error Handling

- Kubernetes handles pod restarts and rescheduling
- PVCs ensure data persistence
- Service discovery provides stable endpoints

## Testing Strategy

- Helm template validates StatefulSet and Service creation
- Dry-run deployment checks resource relationships
- Integration tests verify Authentik connectivity to databases

## Security Considerations

- Database passwords stored in Kubernetes secrets
- Network policies restrict access between components
- No external database exposure

## Implementation Notes

- Uses StatefulSets for stable pod identity
- PVCs use default storage class
- Services use ClusterIP for internal access only