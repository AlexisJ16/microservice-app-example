#!/bin/bash
# Script para acceder a la aplicación vía port-forward

echo "🌐 Iniciando port-forward al Ingress Controller..."
echo ""
echo "La aplicación estará disponible en: http://localhost:8080"
echo ""
echo "Presiona Ctrl+C para detener"
echo ""

kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
