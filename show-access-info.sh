#!/bin/bash

# Script para mostrar información de acceso a todos los servicios

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 GUÍA DE ACCESO A LOS SERVICIOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verificar que los servicios estén corriendo
echo "🔍 Verificando estado de los servicios..."
echo ""

echo "Aplicación:"
kubectl get pods -n microservices-ns 2>/dev/null || echo "⚠️  Namespace microservices-ns no encontrado"

echo ""
echo "Monitoreo:"
kubectl get pods -n monitoring 2>/dev/null || echo "⚠️  Namespace monitoring no encontrado"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 COMANDOS PARA ACCEDER A LOS SERVICIOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "1️⃣  APLICACIÓN PRINCIPAL (Frontend + APIs):"
echo "   Terminal 1:"
echo "   kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80"
echo ""
echo "   Navegador: http://localhost:8080"
echo "   - Frontend Vue.js"
echo "   - Login en: http://localhost:8080/login"
echo ""

echo "2️⃣  GRAFANA (Dashboards de Monitoreo):"
echo "   Terminal 2:"
echo "   kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo ""
echo "   Navegador: http://localhost:3000"
echo "   Usuario: admin"
echo "   Contraseña: admin123"
echo ""

echo "3️⃣  PROMETHEUS (Métricas):"
echo "   Terminal 3:"
echo "   kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
echo ""
echo "   Navegador: http://localhost:9090"
echo ""

echo "4️⃣  ALERTMANAGER (Alertas):"
echo "   Terminal 4:"
echo "   kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093"
echo ""
echo "   Navegador: http://localhost:9093"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 COMANDOS ÚTILES DE TROUBLESHOOTING"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Ver logs de la aplicación:"
echo "  kubectl logs -n microservices-ns -l app=client --tail=50"
echo "  kubectl logs -n microservices-ns -l app=auth --tail=50"
echo "  kubectl logs -n microservices-ns -l app=users --tail=50"
echo "  kubectl logs -n microservices-ns -l app=posts --tail=50"
echo ""

echo "Ver logs de Grafana:"
echo "  kubectl logs -n monitoring -l app.kubernetes.io/name=grafana --tail=50"
echo ""

echo "Reiniciar un servicio:"
echo "  kubectl rollout restart deployment/client-deployment -n microservices-ns"
echo ""

echo "Ver todos los recursos:"
echo "  kubectl get all -n microservices-ns"
echo "  kubectl get all -n monitoring"
echo ""

# Obtener contraseña de Grafana si existe
if kubectl get secret -n monitoring prometheus-grafana >/dev/null 2>&1; then
    GRAFANA_PASSWORD=$(kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" 2>/dev/null | base64 --decode 2>/dev/null)
    if [ ! -z "$GRAFANA_PASSWORD" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🔐 CONTRASEÑA ACTUAL DE GRAFANA"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Usuario: admin"
        echo "Contraseña: $GRAFANA_PASSWORD"
        echo ""
    fi
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
