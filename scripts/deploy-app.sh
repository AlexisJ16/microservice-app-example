#!/bin/bash

# Script to deploy the microservices application to Kubernetes
# This script builds Docker images and applies all Kubernetes manifests

set -e  # Exit on any error

echo "======================================"
echo "Deploying Microservices Application"
echo "======================================"
echo ""

# Step 1: Build Docker images
echo "[1/5] Building Docker images..."
echo "--------------------------------------"

# Note: Adjust these paths based on your repository structure
# The images should match the service names used in the manifests

echo "Building users-service image..."
if [ -d "./users-api" ]; then
    docker build -t alexisj16/users-service:latest ./users-api
    echo "✓ users-service image built successfully"
else
    echo "⚠ Warning: users-api directory not found, skipping image build"
fi

echo ""
echo "Building posts-service image..."
if [ -d "./todos-api" ]; then
    docker build -t alexisj16/posts-service:latest ./todos-api
    echo "✓ posts-service image built successfully"
else
    echo "⚠ Warning: todos-api directory not found, skipping image build"
fi

echo ""
echo "Building client image..."
if [ -d "./frontend" ]; then
    docker build -t alexisj16/client:latest ./frontend
    echo "✓ client image built successfully"
else
    echo "⚠ Warning: frontend directory not found, skipping image build"
fi

echo ""
echo "[2/5] Creating namespace..."
echo "--------------------------------------"
kubectl apply -f k8s/00-namespace.yaml
echo "✓ Namespace created"

echo ""
echo "[3/5] Applying configuration (ConfigMaps and Secrets)..."
echo "--------------------------------------"
kubectl apply -f k8s/01-app-configmap.yaml
kubectl apply -f k8s/02-app-secret.yaml
echo "✓ Configuration applied"

echo ""
echo "[4/5] Creating persistent storage..."
echo "--------------------------------------"
kubectl apply -f k8s/03-posts-pvc.yaml
echo "✓ PersistentVolumeClaim created"

echo ""
echo "[5/5] Deploying services and workloads..."
echo "--------------------------------------"
kubectl apply -f k8s/04-users-deployment.yaml
echo "✓ Users service deployed"

kubectl apply -f k8s/05-posts-deployment.yaml
echo "✓ Posts service deployed"

kubectl apply -f k8s/06-client-deployment.yaml
echo "✓ Client service deployed"

kubectl apply -f k8s/07-ingress.yaml
echo "✓ Ingress configured"

kubectl apply -f k8s/08-hpa.yaml
echo "✓ HorizontalPodAutoscaler configured"

echo ""
echo "Applying network policies..."
kubectl apply -f k8s/networking/01-default-deny.yaml
kubectl apply -f k8s/networking/02-allow-traffic.yaml
echo "✓ Network policies applied"

echo ""
echo "======================================"
echo "Deployment Complete!"
echo "======================================"
echo ""
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=users-service -n microservices-ns --timeout=120s || true
kubectl wait --for=condition=ready pod -l app=posts-service -n microservices-ns --timeout=120s || true
kubectl wait --for=condition=ready pod -l app=client-service -n microservices-ns --timeout=120s || true

echo ""
echo "Current cluster status:"
echo "--------------------------------------"
kubectl get all,hpa,pvc,ingress -n microservices-ns

echo ""
echo "======================================"
echo "Application is ready!"
echo "======================================"
echo ""
echo "To access the application:"
echo "  - Get the Ingress IP: kubectl get ingress -n microservices-ns"
echo "  - Or use port-forward: kubectl port-forward svc/client-service 3000:3000 -n microservices-ns"
echo ""
