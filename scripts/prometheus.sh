#!/bin/bash
# Script para acceder a Prometheus (métricas)
# IMPORTANTE: Abre este script en una NUEVA terminal

echo "🔍 Creando port-forward a Prometheus..."
echo ""
echo "⚠️  IMPORTANTE: Mantén esta terminal abierta"
echo "   Prometheus estará disponible en: http://localhost:9090"
echo ""
echo "   Presiona Ctrl+C para detener el port-forward"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
