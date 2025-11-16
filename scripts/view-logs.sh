#!/bin/bash
# Script para ver los logs de todos los servicios

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    Logs de los Servicios                      ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

echo "--- AUTH SERVICE ---"
kubectl logs -n microservices-ns -l app=auth --tail=20

echo ""
echo "--- USERS SERVICE ---"
kubectl logs -n microservices-ns -l app=users --tail=20

echo ""
echo "--- POSTS SERVICE ---"
kubectl logs -n microservices-ns -l app=posts --tail=20

echo ""
echo "--- CLIENT (FRONTEND) ---"
kubectl logs -n microservices-ns -l app=client --tail=20
