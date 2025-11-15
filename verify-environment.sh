#!/bin/bash

# Script de verificación pre-vuelo

echo "🔍 Verificando entorno..."
echo ""

# Verificar kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl no está instalado"
    exit 1
fi
echo "✅ kubectl instalado: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"

# Verificar docker
if ! command -v docker &> /dev/null; then
    echo "❌ docker no está instalado"
    exit 1
fi
echo "✅ docker instalado: $(docker --version)"

# Verificar kind
if ! command -v kind &> /dev/null; then
    echo "❌ kind no está instalado"
    exit 1
fi
echo "✅ kind instalado: $(kind version)"

# Verificar cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ No hay conexión con el cluster de Kubernetes"
    exit 1
fi
echo "✅ Cluster de Kubernetes accesible"

# Verificar namespace
kubectl get namespace ingress-nginx &> /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Namespace ingress-nginx existe"
else
    echo "⚠️  Namespace ingress-nginx no existe - puede necesitar configurarse"
fi

# Verificar Ingress Controller
INGRESS_PODS=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx -o jsonpath='{.items[*].status.phase}' 2>/dev/null)
if [[ "$INGRESS_PODS" == *"Running"* ]]; then
    echo "✅ Ingress Controller está corriendo"
else
    echo "⚠️  Ingress Controller no está corriendo correctamente"
fi

echo ""
echo "=========================================="
echo "✅ Verificación completada"
echo "=========================================="
echo ""
echo "Todo listo para ejecutar:"
echo "  bash build-and-deploy.sh"
echo ""
