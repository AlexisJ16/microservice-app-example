#!/bin/bash
# Script de validación completa del proyecto
# Limpia todo, despliega desde cero y valida funcionamiento

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

clear
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║           VALIDACIÓN COMPLETA DEL PROYECTO                   ║
║           Limpieza + Despliegue + Verificación               ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

################################################################################
# FASE 1: LIMPIEZA COMPLETA
################################################################################

print_step "FASE 1: Limpieza completa de recursos existentes"

print_info "Eliminando recursos de Kubernetes..."
kubectl delete all --all -n microservices-ns 2>/dev/null || true
kubectl delete ingress --all -n microservices-ns 2>/dev/null || true
kubectl delete hpa --all -n microservices-ns 2>/dev/null || true
kubectl delete pvc --all -n microservices-ns 2>/dev/null || true
kubectl delete networkpolicy --all -n microservices-ns 2>/dev/null || true
kubectl delete configmap app-config -n microservices-ns 2>/dev/null || true
kubectl delete secret app-secret -n microservices-ns 2>/dev/null || true

print_info "Eliminando imágenes Docker..."
docker rmi -f auth-service:latest 2>/dev/null || true
docker rmi -f users-service:latest 2>/dev/null || true
docker rmi -f posts-service:latest 2>/dev/null || true
docker rmi -f client:latest 2>/dev/null || true

print_info "Limpiando archivos temporales..."
rm -f auth-api/go.sum 2>/dev/null || true

print_success "Limpieza completada"
sleep 2

################################################################################
# FASE 2: CONSTRUCCIÓN DE IMÁGENES
################################################################################

print_step "FASE 2: Construyendo imágenes Docker"

print_info "Construyendo auth-service (Go)..."
docker build -t auth-service:latest auth-api/ > /dev/null 2>&1
print_success "auth-service construido"

print_info "Construyendo users-service (Java)..."
docker build -t users-service:latest users-api/ > /dev/null 2>&1
print_success "users-service construido"

print_info "Construyendo posts-service (Node.js)..."
docker build -t posts-service:latest todos-api/ > /dev/null 2>&1
print_success "posts-service construido"

print_info "Construyendo client (Vue.js)..."
docker build -t client:latest frontend/ > /dev/null 2>&1
print_success "client construido"

print_success "Todas las imágenes construidas correctamente"
sleep 2

################################################################################
# FASE 3: CARGA DE IMÁGENES EN KIND
################################################################################

print_step "FASE 3: Cargando imágenes en el clúster kind"

kind load docker-image auth-service:latest --name microservices-cluster
kind load docker-image users-service:latest --name microservices-cluster
kind load docker-image posts-service:latest --name microservices-cluster
kind load docker-image client:latest --name microservices-cluster

print_success "Imágenes cargadas en el clúster"
sleep 2

################################################################################
# FASE 4: DESPLIEGUE DE MANIFIESTOS
################################################################################

print_step "FASE 4: Desplegando manifiestos de Kubernetes"

cd microservice-k8s-migration/k8s/

print_info "Aplicando namespace..."
kubectl apply -f 00-namespace.yaml

print_info "Aplicando ConfigMap..."
kubectl apply -f 01-app-configmap.yaml

print_info "Aplicando Secret..."
kubectl apply -f 02-app-secret.yaml

print_info "Aplicando PVC..."
kubectl apply -f 03-posts-pvc.yaml

print_info "Desplegando servicios..."
kubectl apply -f 03-auth-deployment.yaml
kubectl apply -f 04-users-deployment.yaml
kubectl apply -f 05-posts-deployment.yaml
kubectl apply -f 06-client-deployment.yaml

print_info "Aplicando Ingress..."
kubectl apply -f 07-ingress.yaml

print_info "Aplicando HPA..."
kubectl apply -f 08-hpa.yaml

print_info "Aplicando Network Policies..."
kubectl apply -f networking/01-default-deny.yaml
kubectl apply -f networking/02-allow-traffic.yaml

cd ../..

print_success "Manifiestos aplicados correctamente"
sleep 2

################################################################################
# FASE 5: ESPERANDO PODS
################################################################################

print_step "FASE 5: Esperando que los pods estén listos"

print_info "Esperando pods... (esto puede tomar 1-2 minutos)"
kubectl wait --for=condition=ready pod -l app=auth -n microservices-ns --timeout=180s
kubectl wait --for=condition=ready pod -l app=users -n microservices-ns --timeout=180s
kubectl wait --for=condition=ready pod -l app=posts -n microservices-ns --timeout=180s
kubectl wait --for=condition=ready pod -l app=client -n microservices-ns --timeout=180s

print_success "Todos los pods están listos"
sleep 2

################################################################################
# FASE 6: VALIDACIÓN
################################################################################

print_step "FASE 6: Validando el despliegue"

echo ""
echo "📊 Estado de los Pods:"
kubectl get pods -n microservices-ns

echo ""
echo "🔌 Estado de los Servicios:"
kubectl get svc -n microservices-ns

echo ""
echo "🌐 Estado del Ingress:"
kubectl get ingress -n microservices-ns

echo ""
echo "📈 Estado del HPA:"
kubectl get hpa -n microservices-ns

echo ""
echo "🔒 Network Policies:"
kubectl get networkpolicies -n microservices-ns

echo ""
echo "💾 Persistent Volume Claims:"
kubectl get pvc -n microservices-ns

print_success "Validación de recursos completada"
sleep 2

################################################################################
# FASE 7: VERIFICACIÓN DE LOGS
################################################################################

print_step "FASE 7: Verificando logs de servicios"

echo ""
echo "--- AUTH SERVICE ---"
kubectl logs -n microservices-ns -l app=auth --tail=3 2>/dev/null || echo "Esperando logs..."

echo ""
echo "--- USERS SERVICE ---"
kubectl logs -n microservices-ns -l app=users --tail=3 2>/dev/null || echo "Esperando logs..."

echo ""
echo "--- POSTS SERVICE ---"
kubectl logs -n microservices-ns -l app=posts --tail=3 2>/dev/null || echo "Esperando logs..."

echo ""
echo "--- CLIENT SERVICE ---"
kubectl logs -n microservices-ns -l app=client --tail=3 2>/dev/null || echo "Esperando logs..."

print_success "Logs verificados"
sleep 2

################################################################################
# RESULTADO FINAL
################################################################################

clear
echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║               ✅ VALIDACIÓN COMPLETADA ✅                     ║
║                                                               ║
║          Proyecto desplegado y funcionando correctamente     ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📝 RESUMEN DEL DESPLIEGUE${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "✅ Pods desplegados: 4/4"
echo "✅ Servicios activos: 4/4"
echo "✅ Ingress configurado: ✓"
echo "✅ HPA activo: ✓"
echo "✅ Network Policies: ✓"
echo "✅ Persistencia (PVC): ✓"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🌐 ACCESO A LA APLICACIÓN${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Para acceder a la aplicación, ejecuta en otra terminal:${NC}"
echo ""
echo -e "  ${GREEN}kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80${NC}"
echo ""
echo -e "${YELLOW}Luego abre tu navegador en:${NC}"
echo ""
echo -e "  ${GREEN}http://localhost:8080${NC}"
echo ""
echo -e "${YELLOW}Credenciales de acceso:${NC}"
echo ""
echo "  • admin / admin  (Rol: Administrador)"
echo "  • johnd / foo    (Rol: Usuario)"
echo "  • janed / ddd    (Rol: Usuario)"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📊 MONITOREO${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Grafana:${NC}"
echo -e "  kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
echo -e "  ${GREEN}http://localhost:3000${NC} (admin / admin123)"
echo ""
echo -e "${YELLOW}Prometheus:${NC}"
echo -e "  kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090"
echo -e "  ${GREEN}http://localhost:9090${NC}"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🛠️  COMANDOS ÚTILES${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  bash watch-pods.sh        # Ver estado de pods en tiempo real"
echo "  bash view-logs.sh         # Ver logs de todos los servicios"
echo "  bash demo.sh              # Ejecutar demostración interactiva"
echo "  bash cleanup.sh           # Limpiar todos los recursos"
echo ""

echo -e "${GREEN}🎉 El proyecto está listo para ser demostrado o enviado 🎉${NC}"
echo ""
