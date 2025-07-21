# pgAdmin4 Helm Chart - AI Coding Agent Instructions

## Project Overview
This is a Kubernetes Helm chart repository for deploying pgAdmin4, a web-based PostgreSQL administration tool. The chart follows standard Helm 3 conventions and supports flexible configuration for various deployment scenarios.

## Architecture & Key Components

### Chart Structure
- **Main chart**: `charts/pgadmin4/` - Single chart following Helm best practices
- **Template organization**: Standard Kubernetes manifests in `templates/` with helper functions in `_helpers.tpl`
- **Configuration layers**: `values.yaml` (defaults) + examples in `examples/` directory

### Core Resources Created
- **Deployment**: Main pgAdmin4 container with configurable replicas, security contexts, and volume mounts
- **Service**: ClusterIP/NodePort/LoadBalancer options with custom port configurations
- **Secret**: Authentication credentials (email/password) with optional existing secret support
- **ConfigMap/Secret**: Server definitions for pre-configured PostgreSQL connections
- **PVC**: Optional persistent storage for pgAdmin4 data
- **Ingress**: Optional ingress with TLS support

## Development Workflows

### Testing & Validation
```bash
# Chart linting and testing (uses ct.yaml config)
helm lint charts/pgadmin4
ct lint --config ct.yaml

# Install for testing
helm install test-pgadmin charts/pgadmin4 -f examples/set-admin-creds.yaml

# Dry run with custom values
helm install --dry-run --debug pgadmin4 charts/pgadmin4 -f custom-values.yaml
```

### CI/CD Pipeline
- **Lint/Test**: GitHub Actions with chart-testing (ct) tool on PRs
- **Publish**: Automatic chart publishing to `helm.runix.net` on main branch
- **Configuration**: See `ct.yaml` for chart-testing settings

## Key Patterns & Conventions

### Template Helpers (`_helpers.tpl`)
- `pgadmin.fullname`: Resource naming with truncation and collision handling
- `pgadmin.labels`: Standard Kubernetes labels (app.kubernetes.io/*)
- `pgadmin.tplToMap`: Template rendering for dynamic configurations
- Always use helpers for consistent naming across resources

### Configuration Patterns
```yaml
# Server definitions support both ConfigMap and Secret storage
serverDefinitions:
  enabled: true
  resourceType: Secret  # or ConfigMap
  servers: {} # Inline definitions with Helm templating support

# Flexible volume mounting for configs/secrets
extraConfigmapMounts: []
extraSecretMounts: []
```

### Security Context Handling
- Dual security contexts: `securityContext` (pod-level) and `containerSecurityContext` (container-level)
- `VolumePermissions.enabled` for init container volume permission fixes
- Service account creation with RBAC controls

### Example-Driven Configuration
Reference `examples/` directory for common patterns:
- `serverdefinitions.yaml`: Pre-configured PostgreSQL server connections
- `set-admin-creds.yaml`: Custom admin credentials setup
- `enable-ldap-integration.yaml`: LDAP authentication configuration

## Integration Points

### External Dependencies
- **Container Registry**: `dpage/pgadmin4` from Docker Hub (configurable registry)
- **PostgreSQL Servers**: External PostgreSQL instances via server definitions
- **Storage**: Kubernetes persistent volumes with configurable storage classes
- **Networking**: Ingress controllers for external access

### Kubernetes API Dependencies
- Deployments, Services, ConfigMaps, Secrets (core/v1)
- PersistentVolumeClaims for storage
- NetworkPolicy for network segmentation
- HorizontalPodAutoscaler for scaling

## Configuration Best Practices

### Resource Naming
Always use the `pgadmin.fullname` helper to ensure consistent naming and avoid collisions:
```yaml
metadata:
  name: {{ include "pgadmin.fullname" . }}
```

### Template Validation
Use conditional blocks for optional features:
```yaml
{{- if .Values.serverDefinitions.enabled }}
# Server definitions resources
{{- end }}
```

### Values Organization
Follow the established pattern in `values.yaml`:
1. Global settings first
2. Image configuration
3. Service configuration
4. Feature toggles (serverDefinitions, ingress, etc.)
5. Resource limits and node assignment last

When adding new features, maintain this structure and add comprehensive documentation to the README.md configuration table.
