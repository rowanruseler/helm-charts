{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "pgadmin.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "pgadmin.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "pgadmin.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ include "pgadmin.name" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
helm.sh/chart: {{ include "pgadmin.chart" . }}
{{- with .Values.commonLabels }}
{{ toYaml .  }}
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
Generate chart secret name
*/}}
{{- define "pgadmin.secretName" -}}
{{ default (include "pgadmin.fullname" .) .Values.existingSecret }}
{{- end -}}

{{/*
Defines a JSON file containing server definitions. This allows connection information to be pre-loaded into the instance of pgAdmin in the container. Note that server definitions are only loaded on first launch, i.e. when the configuration database is created, and not on subsequent launches using the same configuration database.
*/}}
{{- define "pgadmin.serverDefinitions" -}}
{{ tpl ( dict "Servers" .Values.serverDefinitions.servers | toPrettyJson) . }}
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
Renders a value that contains template.
Usage:
{{ include "common.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "common.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Create the name of the namespace
*/}}
{{- define "pgadmin.namespaceName" -}}
{{- default .Release.Namespace .Values.namespace | quote }}
{{- end }}

{{/*
Generate serverDefinitions configMap name
*/}}
{{- define "pgadmin.serverDefinitionsConfigmap" -}}
{{- if eq .Values.serverDefinitions.resourceType "ConfigMap" -}}
    {{- if .Values.serverDefinitions.existingConfigmap }}
        {{- printf "%s" (.Values.serverDefinitions.existingConfigmap) }}
    {{- else }}
        {{- include "pgadmin.fullname" . }}-server-definitions
    {{- end }}
{{- end }}
{{- end }}

{{/*
Generate serverDefinitions secret name
*/}}
{{- define "pgadmin.serverDefinitionsSecret" -}}
{{- if eq .Values.serverDefinitions.resourceType "Secret" -}}
    {{- if .Values.serverDefinitions.existingSecret }}
        {{- printf "%s" (.Values.serverDefinitions.existingSecret) }}
    {{- else if .Values.serverDefinitions.servers }}
        {{- include "pgadmin.fullname" . }}-server-definitions
    {{- else if .Values.existingSecret }}
        {{- printf "%s" (.Values.existingSecret) }}
    {{- end }}
{{- end }}
{{- end }}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "pgadmin.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "pgadmin.validateValues.serverDefinitionsType" .) -}}
{{- $messages := append $messages (include "pgadmin.validateValues.serverDefinitionsContent" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/*
Verify serverDefinitions.resourceType
*/}}
{{- define "pgadmin.validateValues.serverDefinitionsType" -}}
{{- $allowedResourceTypes := list "ConfigMap" "Secret" -}}
{{- if .Values.serverDefinitions.enabled -}}
    {{- if not (has .Values.serverDefinitions.resourceType $allowedResourceTypes) -}}
        pgadmin: serverDefinitions.resourceType
        Invalid value for '.Values.serverDefinitions.resourceType'. Allowed values are either ConfigMap or Secret.
    {{- end }}
{{- end }}
{{- end }}

{{/*
Verify serverDefinitions.content
*/}}
{{- define "pgadmin.validateValues.serverDefinitionsContent" -}}
{{- if .Values.serverDefinitions.enabled -}}
    {{- if and (eq .Values.serverDefinitions.resourceType "ConfigMap") (not .Values.serverDefinitions.servers) (not .Values.serverDefinitions.existingConfigmap) -}}
        pgadmin: serverDefinitions.servers
        One of '.Values.serverDefinitions.servers' or '.Values.serverDefinitions.existingConfigmap' must be defined.
    {{- else if and (eq .Values.serverDefinitions.resourceType "Secret") (not .Values.serverDefinitions.servers) (not .Values.serverDefinitions.existingSecret) (not .Values.existingSecret) -}}
        pgadmin: serverDefinitions.servers
        One of '.Values.serverDefinitions.servers', '.Values.serverDefinitions.existingSecret' or '.Values.existingSecret' must be defined.
    {{- end }}
{{- end }}
{{- end }}
