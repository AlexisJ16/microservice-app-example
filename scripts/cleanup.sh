#!/bin/bash
# Script para limpiar todos los recursos del proyecto

echo "🧹 Limpiando recursos de Kubernetes..."

# Eliminar recursos del namespace
kubectl delete all --all -n microservices-ns 2>/dev/null || true
kubectl delete ingress --all -n microservices-ns 2>/dev/null || true
kubectl delete hpa --all -n microservices-ns 2>/dev/null || true
kubectl delete pvc --all -n microservices-ns 2>/dev/null || true
kubectl delete networkpolicy --all -n microservices-ns 2>/dev/null || true
kubectl delete configmap app-config -n microservices-ns 2>/dev/null || true
kubectl delete secret app-secret -n microservices-ns 2>/dev/null || true

echo "🗑️  Eliminando imágenes Docker locales..."
docker rmi -f auth-service:latest 2>/dev/null || true
docker rmi -f users-service:latest 2>/dev/null || true
docker rmi -f posts-service:latest 2>/dev/null || true
docker rmi -f client:latest 2>/dev/null || true

echo ""
echo "✅ Limpieza completada"
echo ""
echo "Para volver a desplegar, ejecuta: ./scripts/deploy.sh"
