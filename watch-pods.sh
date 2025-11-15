#!/bin/bash
# Script para monitorear el estado de los pods

echo "🔍 Monitoreando pods en namespace microservices-ns..."
echo ""
echo "Presiona Ctrl+C para salir"
echo ""

kubectl get pods -n microservices-ns -w
