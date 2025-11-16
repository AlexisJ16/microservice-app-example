#!/bin/bash
# Script para acceder a Grafana (monitoreo)
# IMPORTANTE: Abre este script en una NUEVA terminal

echo "📊 Creando port-forward a Grafana..."
echo ""
echo "⚠️  IMPORTANTE: Mantén esta terminal abierta"
echo "   Grafana estará disponible en: http://localhost:3000"
echo ""
echo "   Credenciales de Grafana:"
echo "     • Usuario: admin"
echo "     • Password: admin123"
echo ""
echo "   Presiona Ctrl+C para detener el port-forward"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
