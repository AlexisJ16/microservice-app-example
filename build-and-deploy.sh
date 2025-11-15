#!/bin/bash

# Script completo para construir y desplegar la aplicación paso a paso

set -e

echo "=========================================="
echo "INICIO: Construcción y Despliegue Completo"
echo "=========================================="
echo ""

# Paso 1: Limpiar recursos existentes
echo "📦 Paso 1: Limpiando recursos existentes..."
kubectl delete deployment --all -n microservices-ns --ignore-not-found=true 2>/dev/null || true
docker rmi -f auth-service:latest users-service:latest posts-service:latest client:latest 2>/dev/null || true
rm -f /workspaces/microservice-app-example/microservice-k8s-migration/k8s/04-posts-pvc.yaml 2>/dev/null || true
echo "✅ Limpieza completada"
echo ""

# Paso 2: Construir auth-service
echo "🔨 Paso 2: Construyendo auth-service (Go)..."
cd /workspaces/microservice-app-example/auth-api
docker build -t auth-service:latest . 
if [ $? -eq 0 ]; then
    echo "✅ auth-service construido exitosamente"
else
    echo "❌ Error construyendo auth-service"
    exit 1
fi
echo ""

# Paso 3: Construir users-service
echo "🔨 Paso 3: Construyendo users-service (Java/Spring Boot)..."
cd /workspaces/microservice-app-example/users-api
docker build -t users-service:latest .
if [ $? -eq 0 ]; then
    echo "✅ users-service construido exitosamente"
else
    echo "❌ Error construyendo users-service"
    exit 1
fi
echo ""

# Paso 4: Construir posts-service
echo "🔨 Paso 4: Construyendo posts-service (Node.js)..."
cd /workspaces/microservice-app-example/todos-api
docker build -t posts-service:latest .
if [ $? -eq 0 ]; then
    echo "✅ posts-service construido exitosamente"
else
    echo "❌ Error construyendo posts-service"
    exit 1
fi
echo ""

# Paso 5: Construir client
echo "🔨 Paso 5: Construyendo client (Vue.js)..."
cd /workspaces/microservice-app-example/frontend
docker build -t client:latest .
if [ $? -eq 0 ]; then
    echo "✅ client construido exitosamente"
else
    echo "❌ Error construyendo client"
    exit 1
fi
echo ""

# Paso 6: Cargar imágenes en kind
echo "📤 Paso 6: Cargando imágenes en el cluster kind..."
kind load docker-image auth-service:latest --name microservices-cluster
kind load docker-image users-service:latest --name microservices-cluster
kind load docker-image posts-service:latest --name microservices-cluster
kind load docker-image client:latest --name microservices-cluster
echo "✅ Imágenes cargadas en kind"
echo ""

# Paso 7: Aplicar manifiestos de Kubernetes
echo "☸️  Paso 7: Desplegando en Kubernetes..."
cd /workspaces/microservice-app-example/microservice-k8s-migration/k8s

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
kubectl apply -f networking/01-default-deny.yaml
kubectl apply -f networking/02-allow-traffic.yaml

echo "✅ Manifiestos aplicados"
echo ""

# Paso 8: Verificar estado
echo "🔍 Paso 8: Verificando estado de los pods..."
echo ""
kubectl get pods -n microservices-ns
echo ""
echo "=========================================="
echo "✅ DESPLIEGUE COMPLETADO"
echo "=========================================="
echo ""
echo "📋 Información útil:"
echo ""
echo "Ver logs de pods:"
echo "  kubectl logs -n microservices-ns -l app=auth"
echo "  kubectl logs -n microservices-ns -l app=users"
echo "  kubectl logs -n microservices-ns -l app=posts"
echo "  kubectl logs -n microservices-ns -l app=client"
echo ""
echo "Monitorear pods en tiempo real:"
echo "  kubectl get pods -n microservices-ns -w"
echo ""
echo "Port forward para acceder a la aplicación:"
echo "  kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80"
echo ""
echo "Accede a la aplicación en tu navegador cuando los pods estén Ready:"
echo "  http://localhost:8080"
echo ""
