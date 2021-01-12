###### based on [dpage/pgadmin4]

# pgAdmin 4

[pgAdmin4](https://www.pgadmin.org/) is the leading Open Source management tool for Postgres, the world’s most advanced Open Source database. pgAdmin4 is designed to meet the needs of both novice and experienced Postgres users alike, providing a powerful graphical interface that simplifies the creation, maintenance and use of database objects.

## TL;DR;

```console
$ helm repo add runix https://helm.runix.net/
$ helm install runix/pgadmin4
```

## Introduction

This chart bootstraps a [pgAdmin4](https://www.pgadmin.org/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Install the Chart

To install the chart with the release name `my-release`:

```console
$ # Helm 2
$ helm install --name my-release runix/pgadmin4
$ # Helm 3
$ helm install my-release runix/pgadmin4
```

The command deploys pgAdmin4 on the Kubernetes cluster in the default configuration. The configuration section lists the parameters that can be configured durign installation.

> **Tip**: List all releases using `helm list`

## Uninstall the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete --purge my-release
```

The command removes nearly all the Kubernetes components associated with the chart and deletes the release.

## Configuration

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `replicaCount` | Number of pgadmin4 replicas | `1` |
| `image.registry` | Docker image registry | `docker.io` |
| `image.repository` | Docker image | `dpage/pgadmin4` |
| `image.tag` | Docker image tag | `"4.29"` |
| `image.pullPolicy` | Docker image pull policy | `IfNotPresent` |
| `annotations` | Deployment Annotations | `{}` |
| `service.type` | Service type (ClusterIP, NodePort or LoadBalancer) | `ClusterIP` |
| `service.annotations` | Service Annotations | `{}` |
| `service.port` | Service port | `80` |
| `service.portName` | Name of the port on the service | `http` |
| `service.targetPort` | Internal service port | `http` |
| `service.nodePort` | Kubernetes service nodePort | `` |
| `strategy` | Specifies the strategy used to replace old Pods by new ones | `{}` |
| `serverDefinitions.enabled` | Enables Server Definitions | `false` |
| `serverDefinitions.servers` | Pre-configured server parameters | `` |
| `networkPolicy.enabled` | Enables Network Policy | `true` |
| `ingress.enabled` | Enables Ingress | `false` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts.host` | Ingress accepted hostname | `nil` |
| `ingress.hosts.paths` | Ingress paths list | `[]` |
| `ingress.tls` | Ingress TLS configuration | `[]` |
| `extraConfigmapMounts` | Additional configMap volume mounts for pgadmin4 pod | `[]` |
| `extraSecretMounts` | Additional secret volume mounts for pgadmin4 pod | `[]` |
| `extraContainers` | Sidecar containers to add to the pgadmin4 pod  | `"[]"` |
| `extraInitContainers` | Sidecar init containers to add to the pgadmin4 pod  | `"[]"` |
| `env.email` | pgAdmin4 default email. Needed chart reinstall for apply changes | `chart@example.local` |
| `env.password` | pgAdmin4 default password. Needed chart reinstall for apply changes | `SuperSecret` |
| `env.pgpassfile` | Path to pgpasssfile (optional). Needed chart reinstall for apply changes | `` |
| `env.contextPath` | Context path for accessing pgadmin (optional) | `` |
| `persistentVolume.enabled` | If true, pgAdmin4 will create a Persistent Volume Claim | `true` |
| `persistentVolume.accessMode` | Persistent Volume access Mode | `ReadWriteOnce` |
| `persistentVolume.size` | Persistent Volume size | `10Gi` |
| `persistentVolume.storageClass` | Persistent Volume Storage Class | `unset` |
| `securityContext` | Custom [security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) for pgAdmin4 containers | `` |
| `resources` | CPU/memory resource requests/limits | `{}` |
| `livenessProbe` | [liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) initial delay and timeout | `` |
| `readinessProbe` | [readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) initial delay and timeout | `` |
| `VolumePermissions.enabled` | Enables init container that changes volume permissions in the data directory  | `false` |
| `extraInitContainers` | Init containers to launch alongside the app | `[]` |
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `tolerations` | Node tolerations for pod assignment | `[]` |
| `affinity` | Node affinity for pod assignment | `{}` |
| `podAnnotations` | Annotations for pod | `{}` |
| `existingSecret` | The name of an existing secret containing the pgadmin4 default password. | `""` |
| `env.enhanced_cookie_protection` | Allows pgAdmin4 to create session cookies based on IP address | `"False"` |
| `init.resources` | Init container CPU/memory resource requests/limits | `{}` |
| `test.image.registry` | Docker image registry for test | `docker.io` |
| `test.image.repository` | Docker image for test | `busybox` |
| `test.image.tag` | Docker image tag for test| `latest` |
| `test.resources` | CPU/memory resource requests/limits for test | `{}` |
| `test.securityContext` | Custom [security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) for test Pod | `` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```bash
$ # Helm 2
$ helm install runix/pgadmin4 --name my-release \
  --set env.password=SuperSecret
$ # Helm 3
$ helm install my-release runix/pgadmin4 \
  --set env.password=SuperSecret
```

Alternatively, a YAML file that specifies the values for the parameters can be
provided while installing the chart. For example:

```bash
$ # Helm 2
$ helm install runix/pgadmin4 --name my-release -f values.yaml
$ # Helm 3
$ helm install my-release runix/pgadmin4 -f values.yaml
```

> **Tip**: You can use the default [values.yaml](https://github.com/rowanruseler/helm-charts/blob/master/charts/pgadmin4/values.yaml) and look on [examples](https://github.com/rowanruseler/helm-charts/blob/master/charts/pgadmin4/examples/).

[dpage/pgadmin4]: https://hub.docker.com/r/dpage/pgadmin4
