#!/bin/bash
# Script para crear port-forwarding al Ingress Controller
# IMPORTANTE: Mantén esta terminal abierta mientras uses la aplicación

echo "🌐 Creando port-forward al Ingress Controller..."
echo ""
echo "⚠️  IMPORTANTE: Mantén esta terminal abierta"
echo "   La aplicación estará disponible en: http://localhost:8080"
echo ""
echo "   Credenciales:"
echo "     • admin / admin  (Administrador)"
echo "     • johnd / foo    (Usuario)"
echo "     • janed / ddd    (Usuario)"
echo ""
echo "   Presiona Ctrl+C para detener el port-forward"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
