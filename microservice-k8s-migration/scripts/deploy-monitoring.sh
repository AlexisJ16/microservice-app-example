#!/bin/bash

# scripts/deploy-monitoring.sh
# Este script instala una pila de monitoreo completa usando el chart de Helm kube-prometheus-stack.
# Incluye Prometheus para la recolección de métricas, Grafana para la visualización y Alertmanager para las alertas.

set -e

info() {
  echo "INFO: $1"
}

info "Paso 1: Añadiendo y actualizando el repositorio de Helm de Prometheus Community..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

info "Paso 2: Creando el namespace 'monitoring' si no existe..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

info "Paso 3: Instalando el chart de Helm 'kube-prometheus-stack'..."
# Este comando instala Prometheus, Grafana y otros componentes en el namespace 'monitoring'.
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring

info "Instalación de la pila de monitoreo completada."

info "Paso 4: Cómo acceder a Grafana y obtener la contraseña..."
echo "Para acceder al dashboard de Grafana, ejecuta el siguiente comando y abre http://localhost:8080 en tu navegador:"
echo "kubectl port-forward -n monitoring svc/prometheus-grafana 8080:80"
echo ""
echo "El usuario por defecto es 'admin'. Para obtener la contraseña, ejecuta:"
echo "kubectl get secret -n monitoring prometheus-grafana -o jsonpath='{.data.admin-password}' | base64 --decode"
