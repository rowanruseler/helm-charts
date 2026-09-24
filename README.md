# Kubernetes Helm Charts

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Usage

Install from the OCI registry:

```console
helm install my-release oci://ghcr.io/rowanruseler/charts/pgadmin4
```

Or add the Helm repository: `helm repo add runix https://helm.runix.net`

OCI charts are signed with [cosign](https://docs.sigstore.dev/cosign/) keyless signing. To check that a chart came from this repository's release workflow:

```console
cosign verify ghcr.io/rowanruseler/charts/pgadmin4:<version> \
  --certificate-identity https://github.com/rowanruseler/helm-charts/.github/workflows/publish.yaml@refs/heads/main \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

## Charts

| Name | Description |
| ---- | ----------- |
| [pgadmin4](charts/pgadmin4) | pgAdmin 4 is a web based administration tool for the PostgreSQL database |
