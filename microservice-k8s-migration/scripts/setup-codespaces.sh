#!/bin/bash

# scripts/setup-codespaces.sh
# Script para configurar el entorno de Kubernetes en GitHub Codespaces.
# Este script instala kind (Kubernetes in Docker) y las herramientas necesarias.

set -e

info() {
  echo "✓ $1"
}

error() {
  echo "✗ ERROR: $1"
  exit 1
}

info "Iniciando configuración del entorno Kubernetes en Codespaces..."

# 1. Verificar que estamos en Codespaces
if [ -z "$CODESPACES" ]; then
  echo "⚠️  ADVERTENCIA: Este script está optimizado para GitHub Codespaces."
  read -p "¿Deseas continuar de todos modos? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# 2. Instalar kubectl si no está instalado
if ! command -v kubectl &> /dev/null; then
  info "Instalando kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm kubectl
  info "kubectl instalado correctamente."
else
  info "kubectl ya está instalado."
fi

# 3. Instalar kind (Kubernetes in Docker)
if ! command -v kind &> /dev/null; then
  info "Instalando kind..."
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind
  info "kind instalado correctamente."
else
  info "kind ya está instalado."
fi

# 4. Instalar Helm
if ! command -v helm &> /dev/null; then
  info "Instalando Helm..."
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  info "Helm instalado correctamente."
else
  info "Helm ya está instalado."
fi

# 5. Crear un clúster de Kubernetes con kind
if kind get clusters | grep -q "microservices-cluster"; then
  info "El clúster 'microservices-cluster' ya existe."
else
  info "Creando clúster de Kubernetes con kind..."
  cat <<EOF | kind create cluster --name microservices-cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
  info "Clúster creado correctamente."
fi

# 6. Instalar NGINX Ingress Controller
info "Instalando NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

info "Esperando a que el Ingress Controller esté listo..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# 7. Verificar la instalación
info "Verificando la instalación..."
kubectl cluster-info
kubectl get nodes

echo ""
echo "=========================================="
echo "✓ Configuración completada exitosamente!"
echo "=========================================="
echo ""
echo "Ahora puedes ejecutar los siguientes comandos:"
echo "  1. Para desplegar la aplicación:"
echo "     cd microservice-k8s-migration/scripts"
echo "     bash deploy-app.sh"
echo ""
echo "  2. Para desplegar el monitoreo:"
echo "     bash deploy-monitoring.sh"
echo ""
echo "  3. Para limpiar todo:"
echo "     bash cleanup.sh"
echo ""
echo "Nota: En Codespaces, accede a la aplicación usando la función de"
echo "      'Port Forwarding' en el puerto 80 del panel de Puertos."
