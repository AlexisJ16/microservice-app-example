#!/bin/bash

# scripts/cleanup.sh
# Este script limpia todos los recursos creados por los scripts de despliegue.
# Es útil para restablecer el entorno del clúster a un estado limpio.

set -e

info() {
  echo "INFO: $1"
}

info "Paso 1: Eliminando recursos de la aplicación del directorio 'k8s'..."
# El comando delete con -f elimina todos los recursos definidos en los archivos YAML.
# El orden no es crítico para la eliminación, pero se agrupan por lógica.
kubectl delete -f ../k8s/ --ignore-not-found=true

info "Paso 2: Desinstalando el release de Helm 'prometheus' del namespace 'monitoring'..."
# El comando uninstall elimina todos los recursos asociados con el release de Helm.
helm uninstall prometheus -n monitoring --ignore-not-found=true

info "Paso 3: Eliminando los namespaces 'microservices-ns' y 'monitoring'..."
# Se eliminan los namespaces para asegurar que no queden recursos huérfanos.
kubectl delete namespace microservices-ns monitoring --ignore-not-found=true

info "Limpieza completada."
echo "Todos los recursos de la aplicación y el monitoreo han sido eliminados."
