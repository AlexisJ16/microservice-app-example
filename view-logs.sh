#!/bin/bash
# Script para ver logs de todos los servicios

echo "📋 Logs de todos los servicios"
echo "================================"
echo ""

echo "🔐 AUTH SERVICE:"
echo "----------------"
kubectl logs -n microservices-ns -l app=auth --tail=20
echo ""

echo "👥 USERS SERVICE:"
echo "----------------"
kubectl logs -n microservices-ns -l app=users --tail=20
echo ""

echo "📝 POSTS SERVICE:"
echo "----------------"
kubectl logs -n microservices-ns -l app=posts --tail=20
echo ""

echo "🖥️  CLIENT:"
echo "----------------"
kubectl logs -n microservices-ns -l app=client --tail=20
echo ""
