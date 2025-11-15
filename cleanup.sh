#!/bin/bash
# Script para limpiar todo el despliegue

echo "🧹 Limpiando todo el despliegue..."
echo ""

# Eliminar todos los recursos del namespace
kubectl delete all --all -n microservices-ns 2>/dev/null || true
kubectl delete ingress --all -n microservices-ns 2>/dev/null || true
kubectl delete hpa --all -n microservices-ns 2>/dev/null || true
kubectl delete pvc --all -n microservices-ns 2>/dev/null || true
kubectl delete networkpolicy --all -n microservices-ns 2>/dev/null || true
kubectl delete configmap --all -n microservices-ns 2>/dev/null || true
kubectl delete secret --all -n microservices-ns 2>/dev/null || true

# Eliminar imágenes Docker
docker rmi -f auth-service:latest 2>/dev/null || true
docker rmi -f users-service:latest 2>/dev/null || true
docker rmi -f posts-service:latest 2>/dev/null || true
docker rmi -f client:latest 2>/dev/null || true

echo ""
echo "✅ Limpieza completada"
