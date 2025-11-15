#!/bin/bash

# scripts/deploy-app.sh
# Este script automatiza el despliegue completo de la aplicación de microservicios en Kubernetes.

# Salir inmediatamente si un comando falla
set -e

# Función para imprimir mensajes informativos
info() {
  echo "INFO: $1"
}

# 1. Construir imágenes de Docker y cargarlas en kind
info "Paso 1: Construyendo imágenes de Docker..."

CLUSTER_NAME="microservices-cluster"

# Construir imagen de auth-service
info "Construyendo auth-service..."
docker build -t auth-service:latest ../../auth-api/

# Construir imagen de users-service
info "Construyendo users-service..."
docker build -t users-service:latest ../../users-api/

# Construir imagen de posts-service
info "Construyendo posts-service..."
docker build -t posts-service:latest ../../todos-api/

# Construir imagen de client
info "Construyendo client..."
docker build -t client:latest ../../frontend/

# Cargar imágenes en el cluster kind
info "Cargando imágenes en el cluster kind..."
kind load docker-image auth-service:latest --name $CLUSTER_NAME
kind load docker-image users-service:latest --name $CLUSTER_NAME
kind load docker-image posts-service:latest --name $CLUSTER_NAME
kind load docker-image client:latest --name $CLUSTER_NAME

info "Imágenes construidas y cargadas exitosamente."

# 2. Aplicar los manifiestos de Kubernetes
info "Paso 2: Aplicando manifiestos de Kubernetes..."

info "Aplicando Namespace..."
kubectl apply -f ../k8s/00-namespace.yaml

info "Aplicando ConfigMap y Secret..."
kubectl apply -f ../k8s/01-app-configmap.yaml
kubectl apply -f ../k8s/02-app-secret.yaml

info "Aplicando PersistentVolumeClaim..."
kubectl apply -f ../k8s/03-posts-pvc.yaml

info "Aplicando Deployments y Services..."
kubectl apply -f ../k8s/03-auth-deployment.yaml
kubectl apply -f ../k8s/04-users-deployment.yaml
kubectl apply -f ../k8s/05-posts-deployment.yaml
kubectl apply -f ../k8s/06-client-deployment.yaml

info "Aplicando Ingress..."
kubectl apply -f ../k8s/07-ingress.yaml

info "Aplicando HorizontalPodAutoscaler..."
kubectl apply -f ../k8s/08-hpa.yaml

info "Aplicando Políticas de Red..."
kubectl apply -f ../k8s/networking/01-default-deny.yaml
kubectl apply -f ../k8s/networking/02-allow-traffic.yaml

info "Despliegue completado."

# 3. Mostrar el estado de todos los recursos creados
info "Paso 3: Verificando el estado de los recursos en el namespace 'microservices-ns'..."
kubectl get all,hpa,pvc,ingress -n microservices-ns

info "Para acceder a la aplicación, busca la IP del Ingress y abre en tu navegador:"
info "kubectl get ingress -n microservices-ns"
