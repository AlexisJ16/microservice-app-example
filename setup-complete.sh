#!/bin/bash

################################################################################
# SCRIPT DE SETUP COMPLETO CON MONITOREO
# Despliega la aplicación + Prometheus + Grafana
################################################################################

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

print_step "PASO 1: Reconstruir cliente con fix de networking"

echo "📦 Reconstruyendo client..."
docker build -t client:latest frontend/

echo "⬆️  Cargando en kind..."
kind load docker-image client:latest --name microservices-cluster

echo "🔄 Reiniciando deployment del cliente..."
kubectl rollout restart deployment/client-deployment -n microservices-ns
kubectl wait --for=condition=ready pod -l app=client -n microservices-ns --timeout=120s || true

print_step "PASO 2: Desplegar stack de monitoreo (Prometheus + Grafana)"

print_info "Añadiendo repositorio de Helm..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo update

print_info "Creando namespace monitoring..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

print_info "Instalando kube-prometheus-stack (esto tomará 2-3 minutos)..."
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword=admin123 \
  --wait

print_step "PASO 3: Verificando estado"

echo ""
print_info "Pods de la aplicación:"
kubectl get pods -n microservices-ns

echo ""
print_info "Pods de monitoreo:"
kubectl get pods -n monitoring

echo ""
print_step "✅ SETUP COMPLETADO"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📋 ACCESO A LOS SERVICIOS:${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "🌐 APLICACIÓN PRINCIPAL:"
echo "   kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80"
echo "   Abrir: http://localhost:8080"
echo ""
echo "📊 GRAFANA:"
echo "   kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "   Abrir: http://localhost:3000"
echo "   Usuario: admin"
echo "   Contraseña: admin123"
echo ""
echo "📈 PROMETHEUS:"
echo "   kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
echo "   Abrir: http://localhost:9090"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
