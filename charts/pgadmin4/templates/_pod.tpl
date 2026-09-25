{{/*
Pod template shared by deployment.yaml and statefulset.yaml.
*/}}
{{- define "pgadmin.podTemplate" }}
{{- $fullName := include "pgadmin.fullname" . }}
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "pgadmin.name" . }}
        app.kubernetes.io/instance: {{ .Release.Name }}
        {{- with .Values.podLabels }}
        {{- include "pgadmin.tplToMap" (dict "toMap" . "context" $) | nindent 8 }}
        {{- end }}
        {{- with .Values.commonLabels }}
        {{- include "pgadmin.tplToMap" (dict "toMap" . "context" $) | nindent 8 }}
        {{- end }}
    {{- if or (not .Values.existingSecret) .Values.podAnnotations .Values.templatedPodAnnotations (and .Values.serverDefinitions.enabled (not .Values.serverDefinitions.existingConfigmap) (not .Values.serverDefinitions.existingSecret)) (and .Values.preferences.enabled (not .Values.preferences.existingConfigMap)) }}
      annotations:
      {{- if .Values.podAnnotations }}
        {{- .Values.podAnnotations | toYaml | nindent 8 }}
      {{- end }}
      {{- with .Values.templatedPodAnnotations }}
        {{- tpl . $ | nindent 8 }}
      {{- end }}
      {{- if not .Values.existingSecret }}
        checksum/secret: {{ (include (print $.Template.BasePath "/auth-secret.yaml") . | fromYaml).data | toYaml | sha256sum }}
      {{- end }}
      {{- if and .Values.preferences.enabled (not .Values.preferences.existingConfigMap) }}
        checksum/preferences: {{ (include (print .Template.BasePath "/preferences-configmap.yaml") . | fromYaml).data | toYaml | sha256sum }}
      {{- end }}
    {{- end }}
    spec:
    {{- if or .Values.serviceAccount.create .Values.serviceAccount.name }}
      serviceAccountName: {{ default $fullName .Values.serviceAccount.name }}
    {{- end }}
    {{- if .Values.hostAliases }}
      hostAliases:
      {{- range .Values.hostAliases }}
      - ip: {{ .ip | quote }}
        hostnames:
        {{- range .hostnames }}
        - {{ . | quote }}
        {{- end }}
      {{- end }}
    {{- end }}
      automountServiceAccountToken: {{ .Values.serviceAccount.automountServiceAccountToken }}
    {{- if or (.Values.VolumePermissions.enabled) .Values.pgpass.existingSecret .Values.extraInitContainers }}
      initContainers:
      {{- if .Values.VolumePermissions.enabled }}
        - name: init-chmod-data
          image: {{ include "pgadmin.image" . | quote }}
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          command: ["/bin/chown", "-R", "5050:5050", "/var/lib/pgadmin"]
          volumeMounts:
            - name: pgadmin-data
              mountPath: /var/lib/pgadmin
              subPath: "{{ .Values.persistentVolume.subPath }}"
          securityContext:
            runAsUser: 0
          resources:
            {{- .Values.init.resources | toYaml | nindent 12 }}
      {{- end }}
      {{- if .Values.pgpass.existingSecret }}
        - name: init-pgpass
          image: {{ include "pgadmin.image" . | quote }}
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          # libpq ignores a pgpass file unless its mode is 0600, which a Secret mount can't provide.
          command: ["install", "-m", "600", "/pgpass-secret/pgpass", "/pgpass/pgpass"]
          volumeMounts:
            - name: pgpass-secret
              mountPath: /pgpass-secret
              readOnly: true
            - name: pgpass
              mountPath: /pgpass
        {{- if .Values.containerSecurityContext.enabled }}
          securityContext: {{- omit .Values.containerSecurityContext "enabled" | toYaml | nindent 12 }}
        {{- end }}
          resources:
            {{- .Values.init.resources | toYaml | nindent 12 }}
      {{- end }}
      {{- with .Values.extraInitContainers }}
        {{ tpl . $ | nindent 8 }}
      {{- end }}
    {{- end }}
    {{- if .Values.priorityClassName }}
      priorityClassName: "{{ .Values.priorityClassName }}"
    {{- end }}
      containers:
        - name: {{ .Chart.Name }}
          image: {{ include "pgadmin.image" . | quote }}
          imagePullPolicy: {{ .Values.image.pullPolicy }}
        {{- if .Values.containerSecurityContext.enabled }}
          securityContext: {{- omit .Values.containerSecurityContext "enabled" | toYaml | nindent 12 }}
        {{- end }}
        {{- if .Values.command }}
          command:
            {{- toYaml .Values.command | nindent 12 }}
        {{- end }}
        {{- if .Values.args }}
          args:
            {{- toYaml .Values.args | nindent 12 }}
        {{- end }}
          ports:
            - name: {{ .Values.service.portName }}
              containerPort: {{ .Values.containerPorts.http }}
              protocol: TCP
        {{- if .Values.livenessProbe }}
          livenessProbe:
            httpGet:
              port: {{ .Values.service.portName }}
              {{- if .Values.env.contextPath }}
              path: "{{ .Values.env.contextPath }}/misc/ping"
              {{- else }}
              path: /misc/ping
              {{- end }}
              {{- if or (eq (.Values.service.portName | lower) "http") (eq (.Values.service.portName | lower) "https") }}
              scheme: {{ upper .Values.service.portName }}
              {{- end }}
            {{- .Values.livenessProbe | toYaml | nindent 12 }}
        {{- end }}
        {{- if .Values.startupProbe }}
          startupProbe:
            httpGet:
              port: {{ .Values.service.portName }}
              {{- if .Values.env.contextPath }}
              path: "{{ .Values.env.contextPath }}/misc/ping"
              {{- else }}
              path: /misc/ping
              {{- end }}
              {{- if or (eq (.Values.service.portName | lower) "http") (eq (.Values.service.portName | lower) "https") }}
              scheme: {{ upper .Values.service.portName }}
              {{- end }}
            {{- .Values.startupProbe | toYaml | nindent 12 }}
        {{- end }}
        {{- if .Values.readinessProbe }}
          readinessProbe:
            httpGet:
              port: {{ .Values.service.portName }}
              {{- if .Values.env.contextPath }}
              path: "{{ .Values.env.contextPath }}/misc/ping"
              {{- else }}
              path: /misc/ping
              {{- end }}
              {{- if or (eq (.Values.service.portName | lower) "http") (eq (.Values.service.portName | lower) "https") }}
              scheme: {{ upper .Values.service.portName }}
              {{- end }}
            {{- .Values.readinessProbe | toYaml | nindent 12 }}
        {{- end }}
          env:
          {{- with .Values.envVarsExtra }}
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with include "pgadmin.env" . }}
            {{- . | nindent 12 }}
          {{- end }}
          {{- range .Values.env.variables }}
            - name: {{ .name | quote }}
              value: {{ .value | quote }}
          {{- end }}
          {{- if or .Values.envVarsFromConfigMaps .Values.envVarsFromSecrets }}
          envFrom:
            {{- range .Values.envVarsFromConfigMaps }}
            - configMapRef:
                name: {{ . | quote }}
            {{- end }}
            {{- range .Values.envVarsFromSecrets }}
            - secretRef:
                name: {{ . | quote }}
            {{- end }}
          {{- end }}
          volumeMounts:
            - name: pgadmin-data
              mountPath: /var/lib/pgadmin
              subPath: "{{ .Values.persistentVolume.subPath }}"
          {{- if and (.Values.serverDefinitions.enabled) (or (eq .Values.serverDefinitions.resourceType "ConfigMap") (eq .Values.serverDefinitions.resourceType "Secret")) -}}
          {{- if or (.Values.serverDefinitions.existingConfigmap) (.Values.serverDefinitions.existingSecret) (.Values.existingSecret) (.Values.serverDefinitions.servers) }}
            - name: definitions
              mountPath: /pgadmin4/servers.json
              subPath: servers.json
          {{- end }}
          {{- end }}
          {{- if .Values.preferences.enabled }}
            - name: preferences
              mountPath: /pgadmin4/preferences.json
              subPath: preferences.json
          {{- end }}
          {{- range .Values.extraConfigmapMounts }}
            - name: {{ .name }}
              mountPath: {{ .mountPath }}
              subPath: {{ .subPath }}
              readOnly: {{ .readOnly }}
          {{- end }}
          {{- range .Values.extraSecretMounts }}
            - name: {{ .name }}
              mountPath: {{ .mountPath }}
              subPath: {{ .subPath }}
              readOnly: {{ .readOnly }}
          {{- end }}
          {{- if .Values.pgpass.existingSecret }}
            - name: pgpass
              mountPath: /pgpass
              readOnly: true
          {{- end }}
          {{- if .Values.extraVolumeMounts }}
            {{- .Values.extraVolumeMounts | toYaml | nindent 12 }}
          {{- end }}
          {{- range include "pgadmin.writableDirs" . | fromJsonArray }}
            - name: {{ .name }}
              mountPath: {{ .path }}
          {{- end }}
          resources:
            {{- .Values.resources | toYaml | nindent 12 }}
    {{- with .Values.extraContainers }}
      {{ tpl . $ | nindent 8 }}
    {{- end }}
      volumes:
      {{- if not .Values.persistentVolume.enabled }}
        - name: pgadmin-data
          emptyDir: {}
      {{- else if .Values.persistentVolume.existingClaim }}
        - name: pgadmin-data
          persistentVolumeClaim:
            claimName: {{ .Values.persistentVolume.existingClaim }}
      {{- else if eq .Values.workload.kind "Deployment" }}
        {{- /* A StatefulSet gets this volume from volumeClaimTemplates. */}}
        - name: pgadmin-data
          persistentVolumeClaim:
            claimName: {{ $fullName }}
      {{- end }}
      {{- range .Values.extraConfigmapMounts }}
        - name: {{ .name }}
          configMap:
            name: {{ tpl (.configMap) $ }}
            defaultMode: {{ .defaultMode | default 256 }}
      {{- end }}
      {{- range .Values.extraSecretMounts }}
        - name: {{ .name }}
          secret:
            secretName: {{ tpl (.secret) $ }}
            defaultMode: {{ .defaultMode | default 256 }}
      {{- end }}
      {{- if .Values.pgpass.existingSecret }}
        - name: pgpass-secret
          secret:
            secretName: {{ .Values.pgpass.existingSecret }}
            defaultMode: 0440
            items:
              - key: {{ .Values.pgpass.key }}
                path: pgpass
        - name: pgpass
          emptyDir: {}
      {{- end }}
      {{- if .Values.extraVolumes }}
        {{- .Values.extraVolumes | toYaml | nindent 8 }}
      {{- end }}
      {{- range include "pgadmin.writableDirs" . | fromJsonArray }}
        - name: {{ .name }}
          emptyDir: {}
      {{- end }}
      {{- if and (.Values.serverDefinitions.enabled) (eq .Values.serverDefinitions.resourceType "Secret") -}}
        {{- if or (.Values.serverDefinitions.existingSecret) (.Values.existingSecret) (.Values.serverDefinitions.servers) }}
        - name: definitions
          secret:
            secretName: {{ include "pgadmin.serverDefinitionsSecret" . }}
        {{- end }}
      {{- else if and (.Values.serverDefinitions.enabled) (eq .Values.serverDefinitions.resourceType "ConfigMap") -}}
        {{ if or (.Values.serverDefinitions.existingConfigmap) (.Values.serverDefinitions.servers) }}
        - name: definitions
          configMap:
            name: {{ include "pgadmin.serverDefinitionsConfigmap" . }}
            items:
            - key: servers.json
              path: servers.json
        {{- end }}
      {{- end }}
      {{- if .Values.preferences.enabled }}
        - name: preferences
          configMap:
            name: {{ .Values.preferences.existingConfigMap | default (printf "%s-preferences" (include "pgadmin.fullname" .)) }}
      {{- end }}
    {{- if or .Values.imagePullSecrets .Values.global.imagePullSecrets }}
    {{- $pullSecrets := include "pgadmin.imagePullSecrets" . }}
      imagePullSecrets:
        {{ $pullSecrets | nindent 8 | trim }}
    {{- end }}
    {{- if .Values.nodeSelector }}
      nodeSelector:
        {{- .Values.nodeSelector | toYaml | nindent 8 }}
    {{- end }}
    {{- if .Values.securityContext }}
      securityContext:
        {{- .Values.securityContext | toYaml | nindent 8 }}
    {{- end }}
    {{- if .Values.affinity }}
      affinity:
        {{- .Values.affinity | toYaml | nindent 8 }}
    {{- end }}
    {{- if .Values.tolerations }}
      tolerations:
        {{- .Values.tolerations | toYaml | nindent 8 }}
    {{- end }}
    {{- with .Values.topologySpreadConstraints }}
      topologySpreadConstraints:
      {{- toYaml . | nindent 8 }}
    {{- end }}
    {{- if .Values.dnsPolicy }}
      dnsPolicy: {{ .Values.dnsPolicy }}
    {{- end }}
    {{- if .Values.dnsConfig }}
      dnsConfig:
        {{- .Values.dnsConfig | toYaml | nindent 8 }}
    {{- end }}
{{- end }}
