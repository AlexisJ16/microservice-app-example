#!/bin/bash

# scripts/deploy-app.sh
# Este script automatiza el despliegue completo de la aplicación de microservicios en Kubernetes.

# Salir inmediatamente si un comando falla
set -e

# Función para imprimir mensajes informativos
info() {
  echo "INFO: $1"
}

# 1. Construir imágenes de Docker (opcional, si se hacen cambios locales)
info "Paso 1: Construyendo imágenes de Docker..."
# Descomenta las siguientes líneas si necesitas construir las imágenes desde el código fuente.
# Asegúrate de estar en el directorio raíz del repositorio.
# (cd ../auth-api && docker build -t alexisj16/users-service:latest .)
# (cd ../todos-api && docker build -t alexisj16/posts-service:latest .)
# (cd ../frontend && docker build -t alexisj16/client:latest .)
info "Paso 1: Omitido. Usando imágenes pre-construidas de Docker Hub."

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
