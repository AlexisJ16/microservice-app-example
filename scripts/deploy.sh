#!/bin/bash
# Script de despliegue completo de la aplicación
# Construye imágenes, las carga en kind y despliega todos los servicios

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Despliegue Completo de Microservicios en K8s          ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

CLUSTER_NAME="microservices-cluster"

# 1. Construir imágenes Docker
echo -e "${YELLOW}[1/4]${NC} Construyendo imágenes Docker..."
docker build -t auth-service:latest auth-api/ > /dev/null 2>&1
echo -e "  ${GREEN}✓${NC} auth-service"
docker build -t users-service:latest users-api/ > /dev/null 2>&1
echo -e "  ${GREEN}✓${NC} users-service"
docker build -t posts-service:latest todos-api/ > /dev/null 2>&1
echo -e "  ${GREEN}✓${NC} posts-service"
docker build -t client:latest frontend/ > /dev/null 2>&1
echo -e "  ${GREEN}✓${NC} client"

# 2. Cargar imágenes en kind
echo -e "${YELLOW}[2/4]${NC} Cargando imágenes en el clúster kind..."
kind load docker-image auth-service:latest --name $CLUSTER_NAME > /dev/null 2>&1
kind load docker-image users-service:latest --name $CLUSTER_NAME > /dev/null 2>&1
kind load docker-image posts-service:latest --name $CLUSTER_NAME > /dev/null 2>&1
kind load docker-image client:latest --name $CLUSTER_NAME > /dev/null 2>&1
echo -e "  ${GREEN}✓${NC} Imágenes cargadas en kind"

# 3. Aplicar manifiestos de Kubernetes
echo -e "${YELLOW}[3/4]${NC} Aplicando manifiestos de Kubernetes..."
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
kubectl apply -f networking/01-default-deny.yaml > /dev/null 2>&1
kubectl apply -f networking/02-allow-traffic.yaml > /dev/null 2>&1

cd ../..
echo -e "  ${GREEN}✓${NC} Manifiestos aplicados"

# 4. Esperar a que los pods estén listos
echo -e "${YELLOW}[4/4]${NC} Esperando que los pods estén listos..."
kubectl wait --for=condition=ready pod -l app=auth -n microservices-ns --timeout=180s > /dev/null 2>&1
kubectl wait --for=condition=ready pod -l app=users -n microservices-ns --timeout=180s > /dev/null 2>&1
kubectl wait --for=condition=ready pod -l app=posts -n microservices-ns --timeout=180s > /dev/null 2>&1
kubectl wait --for=condition=ready pod -l app=client -n microservices-ns --timeout=180s > /dev/null 2>&1
echo -e "  ${GREEN}✓${NC} Todos los pods están listos"

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ✓ Despliegue Completado Exitosamente            ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Para acceder a la aplicación, ejecuta:${NC}"
echo -e "  ${YELLOW}./scripts/port-forward.sh${NC}"
echo ""
echo -e "${BLUE}Para ver el estado de los pods:${NC}"
echo -e "  ${YELLOW}./scripts/watch-pods.sh${NC}"
echo ""
