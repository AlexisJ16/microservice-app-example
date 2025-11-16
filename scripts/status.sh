#!/bin/bash
# Script para verificar el estado actual del despliegue

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║              Estado Actual del Despliegue                     ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

echo "📦 PODS:"
kubectl get pods -n microservices-ns
echo ""

echo "🔌 SERVICIOS:"
kubectl get svc -n microservices-ns
echo ""

echo "🌐 INGRESS:"
kubectl get ingress -n microservices-ns
echo ""

echo "📈 HPA (Horizontal Pod Autoscaler):"
kubectl get hpa -n microservices-ns
echo ""

echo "🔒 NETWORK POLICIES:"
kubectl get networkpolicies -n microservices-ns
echo ""

echo "💾 PERSISTENT VOLUME CLAIMS:"
kubectl get pvc -n microservices-ns
echo ""
