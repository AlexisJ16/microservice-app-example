#!/bin/bash
# Script simple y rápido para construir y desplegar

set -e

echo "🚀 Iniciando construcción y despliegue..."
echo ""

# Limpiar
echo "🧹 Limpiando..."
kubectl delete deployment --all -n microservices-ns 2>/dev/null || true
docker rmi -f auth-service:latest users-service:latest posts-service:latest client:latest 2>/dev/null || true
rm -f auth-api/go.sum 2>/dev/null || true

# Construir auth-service
echo ""
echo "📦 1/4: Construyendo auth-service..."
docker build -t auth-service:latest auth-api/
echo "✅ auth-service listo"

# Construir users-service  
echo ""
echo "📦 2/4: Construyendo users-service (esto tomará varios minutos)..."
docker build -t users-service:latest users-api/
echo "✅ users-service listo"

# Construir posts-service
echo ""
echo "📦 3/4: Construyendo posts-service..."
docker build -t posts-service:latest todos-api/
echo "✅ posts-service listo"

# Construir client
echo ""
echo "📦 4/4: Construyendo client..."
docker build -t client:latest frontend/
echo "✅ client listo"

# Cargar en kind
echo ""
echo "⬆️  Cargando imágenes en kind..."
kind load docker-image auth-service:latest --name microservices-cluster
kind load docker-image users-service:latest --name microservices-cluster
kind load docker-image posts-service:latest --name microservices-cluster
kind load docker-image client:latest --name microservices-cluster
echo "✅ Imágenes cargadas"

# Desplegar
echo ""
echo "☸️  Desplegando en Kubernetes..."
cd microservice-k8s-migration/k8s
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-app-configmap.yaml
kubectl apply -f 02-app-secret.yaml
kubectl apply -f 03-posts-pvc.yaml
kubectl apply -f 03-auth-deployment.yaml
kubectl apply -f 04-users-deployment.yaml
kubectl apply -f 05-posts-deployment.yaml
kubectl apply -f 06-client-deployment.yaml
kubectl apply -f 07-ingress.yaml
kubectl apply -f 08-hpa.yaml
kubectl apply -f networking/

echo ""
echo "✅ COMPLETADO!"
echo ""
kubectl get pods -n microservices-ns
echo ""
echo "Para acceder: kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80"
