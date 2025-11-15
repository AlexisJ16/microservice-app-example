#!/bin/bash
# Script para reconstruir el frontend y actualizar el ingress

set -e

echo "🔧 Reconstruyendo frontend con configuración corregida..."
docker build -t client:latest frontend/

echo "📦 Cargando imagen en kind..."
kind load docker-image client:latest --name microservices-cluster

echo "🔄 Aplicando configuración de Ingress actualizada..."
kubectl apply -f microservice-k8s-migration/k8s/07-ingress.yaml

echo "♻️  Reiniciando deployment del cliente..."
kubectl rollout restart deployment/client-deployment -n microservices-ns

echo "⏳ Esperando que el pod esté listo..."
kubectl wait --for=condition=ready pod -l app=client -n microservices-ns --timeout=120s

echo "✅ Frontend actualizado correctamente"
echo ""
echo "🌐 Accede a http://localhost:8080"
echo "   Credenciales: admin/admin o johnd/foo"
