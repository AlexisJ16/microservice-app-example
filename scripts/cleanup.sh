#!/bin/bash

# Cleanup script to remove all deployed resources
# This script removes all Kubernetes resources and Helm releases

set -e  # Exit on any error

echo "======================================"
echo "Cleaning Up Kubernetes Resources"
echo "======================================"
echo ""

# Step 1: Remove application resources
echo "[1/3] Removing application resources..."
echo "--------------------------------------"

if kubectl get namespace microservices-ns &> /dev/null; then
    echo "Deleting network policies..."
    kubectl delete -f k8s/networking/ --ignore-not-found=true
    
    echo "Deleting HPA..."
    kubectl delete -f k8s/08-hpa.yaml --ignore-not-found=true
    
    echo "Deleting Ingress..."
    kubectl delete -f k8s/07-ingress.yaml --ignore-not-found=true
    
    echo "Deleting deployments and services..."
    kubectl delete -f k8s/06-client-deployment.yaml --ignore-not-found=true
    kubectl delete -f k8s/05-posts-deployment.yaml --ignore-not-found=true
    kubectl delete -f k8s/04-users-deployment.yaml --ignore-not-found=true
    
    echo "Deleting PVC..."
    kubectl delete -f k8s/03-posts-pvc.yaml --ignore-not-found=true
    
    echo "Deleting configuration..."
    kubectl delete -f k8s/02-app-secret.yaml --ignore-not-found=true
    kubectl delete -f k8s/01-app-configmap.yaml --ignore-not-found=true
    
    echo "✓ Application resources deleted"
else
    echo "⚠ Namespace microservices-ns not found, skipping..."
fi

echo ""
echo "[2/3] Removing monitoring stack..."
echo "--------------------------------------"

if kubectl get namespace monitoring &> /dev/null; then
    if helm list -n monitoring | grep -q prometheus; then
        echo "Uninstalling Prometheus Helm release..."
        helm uninstall prometheus -n monitoring
        echo "✓ Prometheus uninstalled"
    else
        echo "⚠ Prometheus release not found, skipping..."
    fi
else
    echo "⚠ Namespace monitoring not found, skipping..."
fi

echo ""
echo "[3/3] Deleting namespaces..."
echo "--------------------------------------"

if kubectl get namespace microservices-ns &> /dev/null; then
    echo "Deleting microservices-ns namespace..."
    kubectl delete namespace microservices-ns --timeout=60s
    echo "✓ microservices-ns namespace deleted"
fi

if kubectl get namespace monitoring &> /dev/null; then
    echo "Deleting monitoring namespace..."
    kubectl delete namespace monitoring --timeout=60s
    echo "✓ monitoring namespace deleted"
fi

echo ""
echo "======================================"
echo "Cleanup Complete!"
echo "======================================"
echo ""
echo "All resources have been removed from the cluster."
echo "To verify, run: kubectl get all --all-namespaces"
echo ""
