#!/bin/bash
# Script de demostración interactiva del proyecto

clear
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   🎯 DEMOSTRACIÓN MICROSERVICIOS EN KUBERNETES 🎯           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Función para pausar y esperar enter
pause() {
    echo ""
    echo "Presiona ENTER para continuar..."
    read
    clear
}

# 1. Estado del clúster
echo "═══════════════════════════════════════════════════════════════"
echo "1️⃣  ESTADO DEL CLÚSTER"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📋 Pods en ejecución:"
kubectl get pods -n microservices-ns
echo ""
echo "🔌 Servicios disponibles:"
kubectl get svc -n microservices-ns
echo ""
echo "🌐 Ingress configurado:"
kubectl get ingress -n microservices-ns
pause

# 2. Verificar HPA
echo "═══════════════════════════════════════════════════════════════"
echo "2️⃣  HORIZONTAL POD AUTOSCALER (HPA)"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📊 Estado del autoscaling:"
kubectl get hpa -n microservices-ns
echo ""
echo "📝 Detalles del HPA:"
kubectl describe hpa users-hpa -n microservices-ns | grep -A 10 "Metrics:"
pause

# 3. Network Policies
echo "═══════════════════════════════════════════════════════════════"
echo "3️⃣  NETWORK POLICIES (SEGURIDAD)"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🔒 Políticas de red aplicadas:"
kubectl get networkpolicies -n microservices-ns
echo ""
echo "🛡️  Política de denegación por defecto:"
kubectl describe networkpolicy default-deny-all -n microservices-ns | grep -A 5 "Spec:"
pause

# 4. ConfigMaps y Secrets
echo "═══════════════════════════════════════════════════════════════"
echo "4️⃣  CONFIGURACIÓN (ConfigMaps & Secrets)"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "⚙️  ConfigMap de la aplicación:"
kubectl get configmap app-config -n microservices-ns -o jsonpath='{.data}' | jq -r 'to_entries[] | "\(.key): \(.value)"'
echo ""
echo "🔐 Secrets disponibles:"
kubectl get secrets -n microservices-ns
pause

# 5. Persistencia
echo "═══════════════════════════════════════════════════════════════"
echo "5️⃣  PERSISTENCIA DE DATOS (PVC)"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "💾 Persistent Volume Claims:"
kubectl get pvc -n microservices-ns
echo ""
kubectl describe pvc posts-data-pvc -n microservices-ns | grep -A 5 "Status:"
pause

# 6. Logs de servicios
echo "═══════════════════════════════════════════════════════════════"
echo "6️⃣  LOGS DE SERVICIOS"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📄 Últimas líneas de cada servicio:"
echo ""
echo "--- AUTH SERVICE ---"
kubectl logs -n microservices-ns -l app=auth --tail=3
echo ""
echo "--- USERS SERVICE ---"
kubectl logs -n microservices-ns -l app=users --tail=3
echo ""
echo "--- POSTS SERVICE ---"
kubectl logs -n microservices-ns -l app=posts --tail=3
echo ""
echo "--- CLIENT (FRONTEND) ---"
kubectl logs -n microservices-ns -l app=client --tail=3
pause

# 7. Monitoreo
echo "═══════════════════════════════════════════════════════════════"
echo "7️⃣  STACK DE MONITOREO"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📊 Componentes de monitoreo:"
kubectl get pods -n monitoring | grep -E "NAME|prometheus-0|grafana|alertmanager"
echo ""
echo "🔍 Servicios de monitoreo:"
kubectl get svc -n monitoring | grep -E "NAME|prometheus|grafana|alertmanager"
pause

# 8. Información de acceso
echo "═══════════════════════════════════════════════════════════════"
echo "8️⃣  INFORMACIÓN DE ACCESO"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "🌐 Para acceder a la aplicación, ejecuta en otra terminal:"
echo ""
echo "   kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80"
echo ""
echo "📱 Aplicación Frontend:"
echo "   URL: http://localhost:8080"
echo "   Credenciales:"
echo "     • admin / admin  (Administrador)"
echo "     • johnd / foo    (Usuario)"
echo "     • janed / ddd    (Usuario)"
echo ""
echo "📊 Grafana (Dashboards):"
echo "   kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
echo "   URL: http://localhost:3000"
echo "   Credenciales: admin / admin123"
echo ""
echo "🔍 Prometheus (Métricas):"
echo "   kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090"
echo "   URL: http://localhost:9090"
echo ""
pause

# Final
echo "═══════════════════════════════════════════════════════════════"
echo "✅  DEMOSTRACIÓN COMPLETADA"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📚 Documentación completa disponible en:"
echo "   • GUIA-DEMOSTRACION.md"
echo "   • PROJECT-COMPLETE.md"
echo "   • DEPLOYMENT-GUIDE.md"
echo ""
echo "🛠️  Scripts útiles:"
echo "   • ./watch-pods.sh       - Ver estado de pods en tiempo real"
echo "   • ./view-logs.sh        - Ver logs de todos los servicios"
echo "   • ./cleanup.sh          - Limpiar todos los recursos"
echo ""
echo "🎉 ¡Proyecto funcionando correctamente!"
echo ""
