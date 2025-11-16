#!/bin/bash
# Script para dar permisos de ejecución a todos los scripts

echo "🔧 Dando permisos de ejecución a los scripts..."

chmod +x scripts/*.sh
chmod +x microservice-k8s-migration/scripts/*.sh

echo "✅ Permisos aplicados correctamente"
echo ""
echo "Scripts disponibles en ./scripts/:"
ls -lh scripts/*.sh
