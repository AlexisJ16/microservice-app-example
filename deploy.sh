#!/bin/bash

################################################################################
# SCRIPT MAESTRO DE DESPLIEGUE
# Construye y despliega la aplicación de microservicios en Kubernetes
################################################################################

set -e  # Salir si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con color
print_step() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Banner inicial
clear
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║     DESPLIEGUE DE APLICACIÓN DE MICROSERVICIOS               ║
║     Kubernetes + Docker + Kind                                ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

################################################################################
# PASO 0: VERIFICACIÓN DEL ENTORNO
################################################################################

print_step "PASO 0: Verificando entorno..."

# Verificar que estamos en el directorio correcto
if [ ! -f "quick-deploy.sh" ]; then
    print_error "Debes ejecutar este script desde /workspaces/microservice-app-example"
    exit 1
fi

# Verificar herramientas necesarias
command -v docker >/dev/null 2>&1 || { print_error "docker no está instalado"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { print_error "kubectl no está instalado"; exit 1; }
command -v kind >/dev/null 2>&1 || { print_error "kind no está instalado"; exit 1; }

print_success "Entorno verificado correctamente"
sleep 1

################################################################################
# PASO 1: LIMPIEZA
################################################################################

print_step "PASO 1: Limpiando recursos existentes..."

# Eliminar deployments anteriores
kubectl delete deployment --all -n microservices-ns 2>/dev/null || true
print_info "Deployments eliminados"

# Eliminar imágenes Docker antiguas
docker rmi -f auth-service:latest 2>/dev/null || true
docker rmi -f users-service:latest 2>/dev/null || true
docker rmi -f posts-service:latest 2>/dev/null || true
docker rmi -f client:latest 2>/dev/null || true
print_info "Imágenes antiguas eliminadas"

# Limpiar go.sum para regenerarlo
rm -f auth-api/go.sum 2>/dev/null || true
print_info "Archivos temporales eliminados"

print_success "Limpieza completada"
sleep 1

################################################################################
# PASO 2: CONSTRUCCIÓN DE IMÁGENES DOCKER
################################################################################

print_step "PASO 2: Construyendo imágenes Docker..."

# 2.1: auth-service (Go)
echo ""
print_info "2.1/4: Construyendo auth-service (Go)..."
if docker build -t auth-service:latest auth-api/ > /tmp/build-auth.log 2>&1; then
    print_success "auth-service construido (30s)"
else
    print_error "Error construyendo auth-service"
    tail -20 /tmp/build-auth.log
    exit 1
fi

# 2.2: posts-service (Node.js)
echo ""
print_info "2.2/4: Construyendo posts-service (Node.js)..."
if docker build -t posts-service:latest todos-api/ > /tmp/build-posts.log 2>&1; then
    print_success "posts-service construido (30s)"
else
    print_error "Error construyendo posts-service"
    tail -20 /tmp/build-posts.log
    exit 1
fi

# 2.3: client (Vue.js)
echo ""
print_info "2.3/4: Construyendo client (Vue.js)..."
if docker build -t client:latest frontend/ > /tmp/build-client.log 2>&1; then
    print_success "client construido (2-3 min)"
else
    print_error "Error construyendo client"
    tail -20 /tmp/build-client.log
    exit 1
fi

# 2.4: users-service (Java/Spring Boot) - Este toma más tiempo
echo ""
print_info "2.4/4: Construyendo users-service (Java/Spring Boot)..."
print_info "⏳ Este proceso tomará 8-10 minutos debido a Maven..."
if docker build -t users-service:latest users-api/; then
    print_success "users-service construido"
else
    print_error "Error construyendo users-service"
    exit 1
fi

print_success "Todas las imágenes construidas exitosamente"
sleep 1

################################################################################
# PASO 3: CARGAR IMÁGENES EN KIND
################################################################################

print_step "PASO 3: Cargando imágenes en el cluster kind..."

CLUSTER_NAME="microservices-cluster"

kind load docker-image auth-service:latest --name $CLUSTER_NAME
kind load docker-image users-service:latest --name $CLUSTER_NAME
kind load docker-image posts-service:latest --name $CLUSTER_NAME
kind load docker-image client:latest --name $CLUSTER_NAME

print_success "Imágenes cargadas en el cluster"
sleep 1

################################################################################
# PASO 4: DESPLIEGUE EN KUBERNETES
################################################################################

print_step "PASO 4: Desplegando en Kubernetes..."

cd microservice-k8s-migration/k8s

# Aplicar manifiestos en orden
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-app-configmap.yaml
kubectl apply -f 02-app-secret.yaml
kubectl apply -f 03-posts-pvc.yaml
kubectl apply -f 03-auth-deployment.yaml
kubectl apply -f 04-users-deployment.yaml
kubectl apply -f 05-posts-deployment.yaml
kubectl apply -f 06-client-deployment.yaml
kubectl apply -f 07-ingress.yaml
kubectl apply -f 08-hpa.yaml
kubectl apply -f networking/01-default-deny.yaml
kubectl apply -f networking/02-allow-traffic.yaml

cd ../..

print_success "Manifiestos aplicados"
sleep 2

################################################################################
# PASO 5: VERIFICACIÓN Y ESTADO
################################################################################

print_step "PASO 5: Verificando despliegue..."

echo ""
print_info "Estado de los pods:"
kubectl get pods -n microservices-ns

echo ""
print_info "Servicios desplegados:"
kubectl get svc -n microservices-ns

echo ""
print_info "Ingress configurado:"
kubectl get ingress -n microservices-ns

################################################################################
# RESUMEN FINAL
################################################################################

echo ""
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║                 ✅ DESPLIEGUE COMPLETADO                     ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
print_success "La aplicación ha sido desplegada exitosamente"
echo ""
print_info "Los pods pueden tardar 1-2 minutos en estar completamente listos"
echo ""

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📋 PRÓXIMOS PASOS:${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "1️⃣  Monitorear pods en tiempo real:"
echo "   kubectl get pods -n microservices-ns -w"
echo ""
echo "2️⃣  Cuando todos estén Ready (1/1), presiona Ctrl+C y ejecuta:"
echo "   kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80"
echo ""
echo "3️⃣  Abre tu navegador en: http://localhost:8080"
echo ""
echo "4️⃣  Ver logs de un servicio (si hay problemas):"
echo "   kubectl logs -n microservices-ns -l app=auth"
echo "   kubectl logs -n microservices-ns -l app=users"
echo "   kubectl logs -n microservices-ns -l app=posts"
echo "   kubectl logs -n microservices-ns -l app=client"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
