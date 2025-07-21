# GEMINI Code-Assist Guide: pgadmin4-helm-chart

This document provides guidance for AI agents working on the pgadmin4-helm-chart repository.

## Project Overview

This repository contains a Helm chart for deploying [pgAdmin4](https://www.pgadmin.org/), a web-based administration tool for PostgreSQL. The chart is located in the `charts/pgadmin4` directory and is the primary focus of this project.

## Key Files and Directories

-   `charts/pgadmin4/`: The main directory for the pgAdmin4 Helm chart.
    -   `Chart.yaml`: Contains metadata about the chart, such as its name, version, and dependencies.
    -   `values.yaml`: Defines the default configuration values for the chart. This is the primary file to modify for configuration changes.
    -   `templates/`: Contains the Kubernetes manifest templates that are rendered by Helm.
        -   `_helpers.tpl`: Defines common Go template helpers used across other templates.
        -   `deployment.yaml`: Defines the pgAdmin4 Kubernetes Deployment.
        -   `service.yaml`: Defines the pgAdmin4 Kubernetes Service.
        -   `ingress.yaml`: Defines the pgAdmin4 Kubernetes Ingress.
        -   Other YAML files define other Kubernetes resources like Secrets, ConfigMaps, etc.
    -   `examples/`: Contains example `values.yaml` files for different configurations.

## Development Workflow

The primary development workflow involves modifying the Helm chart templates and values.

### Making Changes

-   **Configuration Changes:** To change the default behavior of the chart, modify `charts/pgadmin4/values.yaml`.
-   **Template Changes:** To change the generated Kubernetes manifests, modify the corresponding template file in `charts/pgadmin4/templates/`.
-   **Adding Features:** To add new features, you may need to add new templates and values.

### Testing

This project uses `chart-testing` for linting and testing the Helm chart. The configuration for `chart-testing` is in `ct.yaml`.

The CI pipeline in `.github/workflows/lint-test.yaml` automates the testing process. To run the tests locally, you would need to install `helm` and `chart-testing`.

A typical local testing process would be:

1.  Make changes to the chart.
2.  Run `helm lint charts/pgadmin4` to check for syntax errors.
3.  Run `helm template charts/pgadmin4` to render the templates and inspect the output.
4.  For more complex changes, use a local Kubernetes cluster (like `kind` or `minikube`) to install and test the chart. The `kind-config.yaml` can be used for this.

### Conventions

-   Follow standard Helm chart conventions.
-   Use the helper templates in `_helpers.tpl` for common tasks like generating names and labels.
-   When adding new values to `values.yaml`, ensure they are well-documented.
-   When making changes, consider the impact on existing users and document any breaking changes.

## Example: Adding a new environment variable

To add a new environment variable to the pgAdmin4 container:

1.  **Add the variable to `values.yaml`:**
    ```yaml
    # in charts/pgadmin4/values.yaml
    env:
      variables:
        - name: NEW_ENV_VAR
          value: "default_value"
    ```

2.  **Update the `deployment.yaml` template:**
    The `deployment.yaml` likely already has a section for environment variables. You would need to ensure it ranges over the `env.variables` list. If it doesn't, you would add it.
