{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "pgadmin.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "pgadmin.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pgadmin.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Render a value as a map after templating it.
Supports both raw string and map types as input.
*/}}
{{- define "pgadmin.tplToMap" -}}
{{- tpl (ternary .toMap (.toMap | toYaml) (kindIs "string" .toMap)) .context -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "pgadmin.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/name: {{ include "pgadmin.name" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
helm.sh/chart: {{ include "pgadmin.chart" . }}
{{- with .Values.commonLabels }}
{{ include "pgadmin.tplToMap" (dict "toMap" . "context" $) }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pgadmin.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pgadmin.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Return full image path using global or local registry.
*/}}
{{- define "pgadmin.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.image.registry | trimSuffix "/" }}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- if $registry }}
{{- printf "%s/%s:%v" $registry .Values.image.repository $tag }}
{{- else }}
{{- printf "%s:%v" .Values.image.repository $tag }}
{{- end }}
{{- end }}

{{/*
Return list of imagePullSecrets from global and local values.
*/}}
{{- define "pgadmin.imagePullSecrets" -}}
{{- $secrets := concat .Values.global.imagePullSecrets .Values.imagePullSecrets }}
{{- range $secrets }}
{{- if eq (typeOf .) "map[string]interface {}" }}
- {{ toYaml (dict "name" .name) | trim }}
{{- else }}
- name: {{ . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate chart secret name
*/}}
{{- define "pgadmin.secretName" -}}
{{ default (include "pgadmin.fullname" .) .Values.existingSecret }}
{{- end -}}

{{/*
Create the name of the namespace
*/}}
{{- define "pgadmin.namespaceName" -}}
{{- default .Release.Namespace .Values.namespace | quote }}
{{- end }}

{{/*
Return if ingress is stable.
*/}}
{{- define "pgadmin.ingress.isStable" -}}
{{- eq (include "pgadmin.ingress.apiVersion" .) "networking.k8s.io/v1" }}
{{- end }}

{{/*
Return if ingress supports ingressClassName.
*/}}
{{- define "pgadmin.ingress.supportsIngressClassName" -}}
{{- or (eq (include "pgadmin.ingress.isStable" .) "true") (and (eq (include "pgadmin.ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18-0" .Capabilities.KubeVersion.Version)) }}
{{- end }}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "pgadmin.ingress.supportsPathType" -}}
{{- or (eq (include "pgadmin.ingress.isStable" .) "true") (and (eq (include "pgadmin.ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18-0" .Capabilities.KubeVersion.Version)) }}
{{- end }}

{{/*
Defines a JSON file containing server definitions.
Recursively walk through a map or slice and cast string values:
- Convert numeric strings (e.g., "443") to integers
- Convert boolean strings ("true"/"false") to actual bools
Useful for ensuring generated JSON has the correct types.
*/}}
{{- define "pgadmin.serverDefinitionsConvert" -}}
{{- $obj := . }}
{{- if kindIs "map" $obj }}
  {{- range $k, $v := $obj }}
    {{- if kindIs "string" $v }}
      {{- if regexMatch "^[0-9]+$" $v }}
        {{- $_ := set $obj $k (atoi $v) }}
      {{- else if regexMatch "(?i)^(true|false)$" $v }}
        {{- $_ := set $obj $k (eq (lower $v) "true") }}
      {{- end }}
    {{- else }}
      {{- include "pgadmin.serverDefinitionsConvert" $v }}
    {{- end }}
  {{- end }}
{{- else if kindIs "slice" $obj }}
  {{- range $i, $v := $obj }}
    {{- include "pgadmin.serverDefinitionsConvert" $v }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "pgadmin.serverDefinitions" -}}
{{- $raw := tpl (toYaml .Values.serverDefinitions.servers) . | fromYaml }}
{{- include "pgadmin.serverDefinitionsConvert" $raw }}
{{ tpl (toPrettyJson (dict "Servers" $raw)) . }}
{{- end -}}

{{- define "pgadmin.serverDefinitionsConfigmap" -}}
{{- if and .Values.serverDefinitions.enabled (eq .Values.serverDefinitions.resourceType "ConfigMap") -}}
{{- default (printf "%s-server-definitions" (include "pgadmin.fullname" .)) .Values.serverDefinitions.existingConfigmap -}}
{{- end -}}
{{- end -}}

{{- define "pgadmin.serverDefinitionsSecret" -}}
{{- if and .Values.serverDefinitions.enabled (eq .Values.serverDefinitions.resourceType "Secret") -}}
{{- if .Values.serverDefinitions.existingSecret -}}
{{- .Values.serverDefinitions.existingSecret -}}
{{- else if or .Values.serverDefinitions.servers (not .Values.existingSecret) -}}
{{- printf "%s-server-definitions" (include "pgadmin.fullname" .) -}}
{{- else -}}
{{- .Values.existingSecret -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "deployment.apiVersion" -}}
{{- if semverCompare "<1.9.0-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "apps/v1beta2" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for network policy.
*/}}
{{- define "networkPolicy.apiVersion" -}}
{{- if semverCompare "<1.8.0-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "pgadmin.ingress.apiVersion" -}}
{{- if and ($.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) }}
{{- print "networking.k8s.io/v1" }}
{{- else if $.Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" }}
{{- print "networking.k8s.io/v1beta1" }}
{{- else }}
{{- print "extensions/v1beta1" }}
{{- end }}
{{- end }}

{{/*
Renders a value that contains template.
Usage:
{{ include "common.tplvalues.render" (dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "common.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Validation helpers.
*/}}
{{- define "pgadmin.validateValues" -}}
{{- $problems := list -}}
{{- $_ := set $.Values "serverDefinitions" (default (dict) $.Values.serverDefinitions) -}}
{{- $type := default "" $.Values.serverDefinitions.resourceType -}}
{{- if and $.Values.serverDefinitions.enabled (not (or (eq $type "ConfigMap") (eq $type "Secret"))) -}}
{{- $problems = append $problems "serverDefinitions.resourceType must be 'ConfigMap' or 'Secret'" -}}
{{- end -}}
{{- if and $.Values.serverDefinitions.enabled (eq $type "ConfigMap") (not (or $.Values.serverDefinitions.servers $.Values.serverDefinitions.existingConfigmap)) -}}
{{- $problems = append $problems "For serverDefinitions.resourceType=ConfigMap define either serverDefinitions.servers or serverDefinitions.existingConfigmap" -}}
{{- end -}}
{{- if and $.Values.serverDefinitions.enabled (eq $type "Secret") (not (or $.Values.serverDefinitions.servers $.Values.serverDefinitions.existingSecret $.Values.existingSecret)) -}}
{{- $problems = append $problems "For serverDefinitions.resourceType=Secret define serverDefinitions.servers or serverDefinitions.existingSecret" -}}
{{- end -}}
{{- if gt (len $problems) 0 -}}
{{- fail (printf "\nVALUES VALIDATION:\n%s" (join "\n" $problems)) -}}
{{- end -}}
{{- end -}}

{{/*
Env vars the chart sets, minus any name the user sets in envVarsExtra or
env.variables, so the container never gets duplicate names.
*/}}
{{- define "pgadmin.env" -}}
{{- $userSet := list -}}
{{- range concat (.Values.envVarsExtra | default list) (.Values.env.variables | default list) -}}
{{- $userSet = append $userSet .name -}}
{{- end -}}
{{- $env := list -}}
{{- /* The pgAdmin image switches to 8080 in restricted security contexts otherwise. */ -}}
{{- $env = append $env (dict "name" "PGADMIN_LISTEN_PORT" "value" (toString .Values.containerPorts.http)) -}}
{{- $env = append $env (dict "name" "PGADMIN_CONFIG_ENHANCED_COOKIE_PROTECTION" "value" (toString .Values.env.enhanced_cookie_protection)) -}}
{{- $env = append $env (dict "name" "PGADMIN_DEFAULT_EMAIL" "value" (toString .Values.env.email)) -}}
{{- $pgpassfile := .Values.env.pgpassfile | default (ternary "/pgpass/pgpass" "" (not (empty .Values.pgpass.existingSecret))) -}}
{{- if $pgpassfile -}}
{{- $env = append $env (dict "name" "PGPASSFILE" "value" (toString $pgpassfile)) -}}
{{- end -}}
{{- $passwordRef := dict "name" (include "pgadmin.fullname" .) "key" "password" -}}
{{- if .Values.existingSecret -}}
{{- $passwordRef = dict "name" .Values.existingSecret "key" .Values.secretKeys.pgadminPasswordKey -}}
{{- end -}}
{{- $env = append $env (dict "name" "PGADMIN_DEFAULT_PASSWORD" "valueFrom" (dict "secretKeyRef" $passwordRef)) -}}
{{- if .Values.env.contextPath -}}
{{- $env = append $env (dict "name" "SCRIPT_NAME" "value" (toString .Values.env.contextPath)) -}}
{{- end -}}
{{- if and .Values.serverDefinitions.enabled (has .Values.serverDefinitions.resourceType (list "ConfigMap" "Secret")) (or .Values.serverDefinitions.existingConfigmap .Values.serverDefinitions.existingSecret .Values.existingSecret .Values.serverDefinitions.servers) -}}
{{- $env = append $env (dict "name" "PGADMIN_SERVER_JSON_FILE" "value" "/pgadmin4/servers.json") -}}
{{- end -}}
{{- if .Values.preferences.enabled -}}
{{- $env = append $env (dict "name" "PGADMIN_PREFERENCES_JSON_FILE" "value" "/pgadmin4/preferences.json") -}}
{{- end -}}
{{- $filtered := list -}}
{{- range $env -}}
{{- if not (has .name $userSet) -}}
{{- $filtered = append $filtered . -}}
{{- end -}}
{{- end -}}
{{- with $filtered -}}
{{- toYaml . -}}
{{- end -}}
{{- end -}}

{{/*
Writable emptyDirs pgAdmin needs with a read-only root filesystem, as a JSON
list of {name, path}. Paths the user already mounts are left out.
*/}}
{{- define "pgadmin.writableDirs" -}}
{{- $dirs := list -}}
{{- if and .Values.containerSecurityContext.enabled .Values.containerSecurityContext.readOnlyRootFilesystem -}}
{{- $taken := list -}}
{{- range .Values.extraVolumeMounts | default list -}}
{{- $taken = append $taken .mountPath -}}
{{- end -}}
{{- range $name, $path := dict "pgadmin-tmp" "/tmp" "pgadmin-logs" "/var/log/pgadmin" -}}
{{- if not (has $path $taken) -}}
{{- $dirs = append $dirs (dict "name" $name "path" $path) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- toJson $dirs -}}
{{- end -}}
