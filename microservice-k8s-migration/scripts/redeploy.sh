#!/bin/bash

# Script para limpiar y redesplegar la aplicación con las imágenes correctas

set -e

echo "======================================"
echo "Limpieza y redespliegue de la aplicación"
echo "======================================"

# 1. Eliminar deployments existentes
echo "1. Eliminando deployments existentes..."
kubectl delete deployment --all -n microservices-ns --ignore-not-found=true

# 2. Eliminar imágenes antiguas de Docker si existen
echo "2. Limpiando imágenes antiguas de Docker..."
docker rmi -f auth-service:latest 2>/dev/null || true
docker rmi -f users-service:latest 2>/dev/null || true
docker rmi -f posts-service:latest 2>/dev/null || true
docker rmi -f client:latest 2>/dev/null || true

# 3. Eliminar archivo duplicado si existe
rm -f /workspaces/microservice-app-example/microservice-k8s-migration/k8s/04-posts-pvc.yaml 2>/dev/null || true

# 4. Ejecutar el script de despliegue
echo "3. Ejecutando deploy-app.sh..."
bash /workspaces/microservice-app-example/microservice-k8s-migration/scripts/deploy-app.sh

echo ""
echo "======================================"
echo "Proceso completado"
echo "======================================"
echo ""
echo "Verificando estado de los pods..."
kubectl get pods -n microservices-ns

echo ""
echo "Esperando a que los pods estén listos (esto puede tomar varios minutos)..."
echo "Puedes monitorear el progreso con: kubectl get pods -n microservices-ns -w"
