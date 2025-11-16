#!/bin/bash
# Script de validación completa del proyecto
# Limpia, reconstruye y despliega todo desde cero

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Validación Completa del Proyecto                   ║${NC}"
echo -e "${BLUE}║     Limpieza → Construcción → Despliegue → Verificación      ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. Limpieza
echo -e "${YELLOW}[1/5]${NC} Limpiando recursos existentes..."
./scripts/cleanup.sh > /dev/null 2>&1
echo -e "  ${GREEN}✓${NC} Limpieza completada"

# 2. Construcción de imágenes
echo -e "${YELLOW}[2/5]${NC} Construyendo imágenes Docker..."
docker build -t auth-service:latest auth-api/ > /dev/null 2>&1
docker build -t users-service:latest users-api/ > /dev/null 2>&1
docker build -t posts-service:latest todos-api/ > /dev/null 2>&1
docker build -t client:latest frontend/ > /dev/null 2>&1
echo -e "  ${GREEN}✓${NC} Imágenes construidas"

# 3. Carga en kind
echo -e "${YELLOW}[3/5]${NC} Cargando imágenes en kind..."
kind load docker-image auth-service:latest --name microservices-cluster > /dev/null 2>&1
kind load docker-image users-service:latest --name microservices-cluster > /dev/null 2>&1
kind load docker-image posts-service:latest --name microservices-cluster > /dev/null 2>&1
kind load docker-image client:latest --name microservices-cluster > /dev/null 2>&1
echo -e "  ${GREEN}✓${NC} Imágenes cargadas"

# 4. Despliegue
echo -e "${YELLOW}[4/5]${NC} Desplegando en Kubernetes..."
cd microservice-k8s-migration/k8s/
kubectl apply -f 00-namespace.yaml > /dev/null 2>&1
kubectl apply -f 01-app-configmap.yaml > /dev/null 2>&1
kubectl apply -f 02-app-secret.yaml > /dev/null 2>&1
kubectl apply -f 03-posts-pvc.yaml > /dev/null 2>&1
kubectl apply -f 03-auth-deployment.yaml > /dev/null 2>&1
kubectl apply -f 04-users-deployment.yaml > /dev/null 2>&1
kubectl apply -f 05-posts-deployment.yaml > /dev/null 2>&1
kubectl apply -f 06-client-deployment.yaml > /dev/null 2>&1
kubectl apply -f 07-ingress.yaml > /dev/null 2>&1
kubectl apply -f 08-hpa.yaml > /dev/null 2>&1
kubectl apply -f networking/ > /dev/null 2>&1
cd ../..
echo -e "  ${GREEN}✓${NC} Manifiestos aplicados"

# 5. Esperar pods
echo -e "${YELLOW}[5/5]${NC} Esperando que los pods estén listos (puede tomar 1-2 min)..."
kubectl wait --for=condition=ready pod -l app=auth -n microservices-ns --timeout=180s > /dev/null 2>&1
kubectl wait --for=condition=ready pod -l app=users -n microservices-ns --timeout=180s > /dev/null 2>&1
kubectl wait --for=condition=ready pod -l app=posts -n microservices-ns --timeout=180s > /dev/null 2>&1
kubectl wait --for=condition=ready pod -l app=client -n microservices-ns --timeout=180s > /dev/null 2>&1
echo -e "  ${GREEN}✓${NC} Todos los pods listos"

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                ✓ Validación Completada ✓                     ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Mostrar estado
echo "📊 Estado de los recursos:"
echo ""
kubectl get pods -n microservices-ns
echo ""
kubectl get svc -n microservices-ns
echo ""
kubectl get ingress -n microservices-ns
echo ""

echo -e "${BLUE}🚀 Para acceder a la aplicación:${NC}"
echo -e "  ${YELLOW}./scripts/port-forward.sh${NC}"
echo ""
