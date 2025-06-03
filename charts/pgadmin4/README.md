###### based on [dpage/pgadmin4]

# pgAdmin 4

[pgAdmin4](https://www.pgadmin.org/) is the leading Open Source management tool for Postgres, the world’s most advanced Open Source database. pgAdmin4 is designed to meet the needs of both novice and experienced Postgres users alike, providing a powerful graphical interface that simplifies the creation, maintenance and use of database objects.

## Prerequisites

* Kubernetes 1.19+
* Helm 3.7+

## TL;DR;

```console
helm repo add runix https://helm.runix.net
helm install pgadmin4 runix/pgadmin4
```

## Introduction

This chart bootstraps a [pgAdmin4](https://www.pgadmin.org/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Install the Chart

To install the chart with the release name `my-release`:

```console
helm install my-release runix/pgadmin4
```

The command deploys pgAdmin4 on the Kubernetes cluster in the default configuration. The configuration section lists the parameters that can be configured during installation.

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
| `global.imageRegistry` | Global image pull registry for all images | `""` |
| `global.imagePullSecrets` | Global image pull secrets, support both full format (- name: secret) and short format (- secret) | `[]` |
| `replicaCount` | Number of pgadmin4 replicas | `1` |
| `image.registry` | Docker image registry | `docker.io` |
| `image.repository` | Docker image | `dpage/pgadmin4` |
| `image.tag` | Docker image tag | `""` |
| `image.pullPolicy` | Docker image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Docker image pull secrets | `[]` |
| `annotations` | Deployment Annotations | `{}` |
| `revisionHistoryLimit` | The number of old history to retain to allow rollback | `10` |
| `commonLabels` | Add labels to all the deployed resources | `{}` |
| `priorityClassName` | Deployment priorityClassName | `""` |
| `command` | Deployment command override | `""` |
| `service.type` | Service type (ClusterIP, NodePort or LoadBalancer) | `ClusterIP` |
| `service.clusterIP` | Service type Cluster IP | `""` |
| `service.loadBalancerIP` | Service Load Balancer IP | `""` |
| `service.annotations` | Service Annotations | `{}` |
| `service.port` | Service port | `80` |
| `service.portName` | Name of the port on the service | `http` |
| `service.targetPort` | Internal service port | `http` |
| `service.nodePort` | Kubernetes service nodePort | `` |
| `serviceAccount.create` | Creates a ServiceAccount for the pod. | `false` |
| `serviceAccount.annotations` | Annotations to add to the service account. | `{}` |
| `serviceAccount.name` | The name of the service account. Otherwise uses the fullname. | `` |
| `serviceAccount.automountServiceAccountToken` | Opt out of API credential automounting. | `false` |
| `hostAliases` | Add entries to Pod /etc/hosts | `` |
| `strategy` | Specifies the strategy used to replace old Pods by new ones | `{}` |
| `serverDefinitions.enabled` | Enables Server Definitions | `false` |
| `serverDefinitions.resourceType` | The type of resource to deploy server definitions (either `ConfigMap` or `Secret`) | `ConfigMap` |
| `serverDefinitions.existingConfigmap` | The name of a configMap containing Server Definitions. Only used when `serverDefinitions.resourceType` is `ConfigMap` | `""` |
| `serverDefinitions.existingSecret` | The name of a Secret containing Server Definitions. Only used when `serverDefinitions.resourceType` is `Secret` | `""` |
| `serverDefinitions.useStringData` | When `resourceType` = `Secret` put raw JSON under `stringData:` instead of base-64 under `data:`. Useful for debugging | `false` |
| `serverDefinitions.servers` | Pre-configured server parameters | `{}` |
| `preferences.enabled` | Specify if to create preferences configmap and mount it | `false` |
| `preferences.existingConfigMap` | The name of a configMap containing your Preferences | `""` |
| `preferences.data` | Preferences Data | `{}` |
| `networkPolicy.enabled` | Enables Network Policy | `true` |
| `ingress.enabled` | Enables Ingress | `false` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.labels` | Custom labels | `{}` |
| `ingress.ingressClassName` | Ingress Class Name. MAY be required for Kubernetes versions >= 1.18 | `""` |
| `ingress.hosts.host` | Ingress accepted hostname | `nil` |
| `ingress.hosts.paths` | Ingress paths list | `[]` |
| `ingress.hosts.paths.path` | Ingress accepted path | `/` |
| `ingress.hosts.paths.pathType` | Ingress type of path | `Prefix` |
| `ingress.tls` | Ingress TLS configuration | `[]` |
| `extraConfigmapMounts` | Additional configMap volume mounts for pgadmin4 pod | `[]` |
| `extraSecretMounts` | Additional secret volume mounts for pgadmin4 pod | `[]` |
| `extraContainers` | Sidecar containers to add to the pgadmin4 pod  | `"[]"` |
| `existingSecret` | The name of an existing secret containing the pgadmin4 default password and, optionally, Server Definitions. | `""` |
| `secretKeys.pgadminPasswordKey` | Name of key in existing secret to use for default pgadmin credentials. Only used when `existingSecret` is set. | `"password"` |
| `extraInitContainers` | Sidecar init containers to add to the pgadmin4 pod  | `"[]"` |
| `env.email` | pgAdmin4 default email. Needed chart reinstall for apply changes | `chart@domain.com` |
| `env.password` | pgAdmin4 default password. Needed chart reinstall for apply changes | `SuperSecret` |
| `env.pgpassfile` | Path to pgpasssfile (optional). Needed chart reinstall for apply changes | `` |
| `env.enhanced_cookie_protection` | Allows pgAdmin4 to create session cookies based on IP address | `"False"` |
| `env.contextPath` | Context path for accessing pgadmin (optional) | `` |
| `envVarsFromConfigMaps` | Array of ConfigMap names to load as environment variables | `[]` |
| `envVarsFromSecrets` | Array of Secret names to load as environment variables | `[]` |
| `envVarsExtra` | Array of arbitrary environment variable definitions (e.g., for fetching from Kubernetes Secrets) | `[]` |
| `persistentVolume.enabled` | If true, pgAdmin4 will create a Persistent Volume Claim | `true` |
| `persistentVolume.accessMode` | Persistent Volume access Mode | `ReadWriteOnce` |
| `persistentVolume.size` | Persistent Volume size | `10Gi` |
| `persistentVolume.storageClass` | Persistent Volume Storage Class | `unset` |
| `persistentVolume.existingClaim` | Persistent Volume existing claim name | | `unset` |
| `persistentVolume.subPath` | Subdirectory of the volume to mount at | `unset` |
| `securityContext` | Custom [pod security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) for pgAdmin4 pod | `` |
| `containerSecurityContext` | Custom [security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) for pgAdmin4 container | `` |
| `livenessProbe` | [liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) initial delay and timeout | `` |
| `startupProbe` | [startup probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) initial delay and timeout | `` |
| `readinessProbe` | [readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) initial delay and timeout | `` |
| `VolumePermissions.enabled` | Enables init container that changes volume permissions in the data directory  | `false` |
| `extraDeploy` | list of extra manifests to deploy | `[]` |
| `extraInitContainers` | Init containers to launch alongside the app | `[]` |
| `containerPorts.http` | Sets http port inside pgadmin container | `80` |
| `resources` | CPU/memory resource requests/limits | `{}` |
| `autoscaling.enabled` | Enables Autoscaling | `false` |
| `autoscaling.minReplicas` | Minimum amount of Replicas | `1` |
| `autoscaling.maxReplicas` | Maximum amount of Replicas| `100` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU Utilization in percentage | `80` |
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `tolerations` | Node tolerations for pod assignment | `[]` |
| `affinity` | Node affinity for pod assignment | `{}` |
| `dnsPolicy` | DNS policy for pods  | `""` |
| `dnsConfig` | DNS config for pods  | `{}` |
| `podAnnotations` | Annotations for pod | `{}` |
| `templatedPodAnnotations` | Templated annotations for pod | `{}` |
| `podLabels` | Labels for pod | `{}` |
| `namespace` | Namespace where to deploy resources | `null` |
| `init.resources` | Init container CPU/memory resource requests/limits | `{}` |
| `test.enabled` | Enables test | `true` |
| `test.image.registry` | Docker image registry for test | `docker.io` |
| `test.image.repository` | Docker image for test | `busybox` |
| `test.image.tag` | Docker image tag for test| `latest` |
| `test.resources` | CPU/memory resource requests/limits for test | `{}` |
| `test.securityContext` | Custom [security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) for test Pod | `` |
| `test.containerSecurityContext` | Custom [pod security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) for test pod | `` |

> The values for "extraConfigmapMounts.[].configMap" and "extraSecretMounts.[].secret" can be either a simple string
or a template string.
Then it will be resolved for you.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```console
helm install my-release runix/pgadmin4 \
  --set env.password=SuperSecret
```

Alternatively, a YAML file that specifies the values for the parameters can be
provided while installing the chart. For example:

```console
helm install my-release runix/pgadmin4 -f values.yaml
```

> **Tip**: You can use the default [values.yaml](https://github.com/rowanruseler/helm-charts/blob/main/charts/pgadmin4/values.yaml) and look on [examples](https://github.com/rowanruseler/helm-charts/blob/main/charts/pgadmin4/examples/).

[dpage/pgadmin4]: https://hub.docker.com/r/dpage/pgadmin4
