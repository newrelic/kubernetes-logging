{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "newrelic.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "newrelic.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if ne $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{/* Generate basic labels */}}
{{- define "newrelic.labels" }}
app: {{ template "newrelic.name" . }}
chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
heritage: {{.Release.Service }}
release: {{.Release.Name }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "newrelic.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "newrelic.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "newrelic.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Create the name of the fluent bit config
*/}}
{{- define "newrelic.fluentBitConfig" -}}
{{ template "newrelic.fullname" . }}-fluent-bit-config
{{- end -}}

{{/*
Return the licenseKey
*/}}
{{- define "newrelic.licenseKey" -}}
{{- if .Values.global}}
  {{- if .Values.global.licenseKey }}
      {{- .Values.global.licenseKey -}}
  {{- else -}}
      {{- .Values.licenseKey | default "" -}}
  {{- end -}}
{{- else -}}
    {{- .Values.licenseKey | default "" -}}
{{- end -}}
{{- end -}}

{{/*
Return the customSecretName
*/}}
{{- define "newrelic.customSecretName" -}}
{{- if .Values.global }}
  {{- if .Values.global.customSecretName }}
      {{- .Values.global.customSecretName -}}
  {{- else -}}
      {{- .Values.customSecretName | default "" -}}
  {{- end -}}
{{- else -}}
    {{- .Values.customSecretName | default "" -}}
{{- end -}}
{{- end -}}

{{/*
Return the customSecretKey
*/}}
{{- define "newrelic.customSecretKey" -}}
{{- if .Values.global }}
  {{- if .Values.global.customSecretKey }}
      {{- .Values.global.customSecretKey -}}
  {{- else -}}
      {{- .Values.customSecretKey | default "" -}}
  {{- end -}}
{{- else -}}
    {{- .Values.customSecretKey | default "" -}}
{{- end -}}
{{- end -}}

{{/*
Returns if the template should render, it checks if the required values are set.
*/}}
{{- define "newrelic.areValuesValid" -}}
{{- $licenseKey := include "newrelic.licenseKey" . -}}
{{- $customSecretName := include "newrelic.customSecretName" . -}}
{{- $customSecretKey := include "newrelic.customSecretKey" . -}}
{{- and (or $licenseKey (and $customSecretName $customSecretKey))}}
{{- end -}}
