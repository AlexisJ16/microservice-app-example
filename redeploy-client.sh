#!/bin/bash
# Script rápido para reconstruir y redesplegar solo el cliente

echo "🔄 Reconstruyendo y redesplegando client..."

# Reconstruir
echo "📦 Construyendo nueva imagen..."
docker build -t client:latest frontend/

# Cargar en kind
echo "⬆️  Cargando en kind..."
kind load docker-image client:latest --name microservices-cluster

# Reiniciar deployment
echo "🔄 Reiniciando deployment..."
kubectl rollout restart deployment/client-deployment -n microservices-ns

echo "✅ Hecho! Esperando a que el pod esté listo..."
kubectl wait --for=condition=ready pod -l app=client -n microservices-ns --timeout=60s

echo ""
echo "Estado del pod:"
kubectl get pods -n microservices-ns -l app=client
