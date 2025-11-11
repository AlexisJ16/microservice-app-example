#!/bin/bash

# Script to deploy the Prometheus and Grafana monitoring stack
# Uses Helm to install kube-prometheus-stack

set -e  # Exit on any error

echo "======================================"
echo "Deploying Monitoring Stack"
echo "======================================"
echo ""

# Step 1: Check if Helm is installed
echo "[1/4] Checking prerequisites..."
echo "--------------------------------------"
if ! command -v helm &> /dev/null; then
    echo "❌ Error: Helm is not installed."
    echo "Please install Helm from: https://helm.sh/docs/intro/install/"
    exit 1
fi
echo "✓ Helm is installed"

echo ""
echo "[2/4] Adding Prometheus Helm repository..."
echo "--------------------------------------"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
echo "✓ Prometheus repository added and updated"

echo ""
echo "[3/4] Creating monitoring namespace..."
echo "--------------------------------------"
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
echo "✓ Monitoring namespace created"

echo ""
echo "[4/4] Installing kube-prometheus-stack..."
echo "--------------------------------------"
echo "This may take several minutes..."
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
  --wait \
  --timeout=10m

echo "✓ Monitoring stack installed successfully"

echo ""
echo "======================================"
echo "Deployment Complete!"
echo "======================================"
echo ""

# Wait for pods to be ready
echo "Waiting for monitoring pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s || true
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=300s || true

echo ""
echo "Current monitoring stack status:"
echo "--------------------------------------"
kubectl get pods -n monitoring

echo ""
echo "======================================"
echo "Access Instructions"
echo "======================================"
echo ""
echo "To access Grafana:"
echo "--------------------------------------"
echo "1. Port-forward the Grafana service:"
echo "   kubectl port-forward svc/prometheus-grafana 8080:80 -n monitoring"
echo ""
echo "2. Open your browser to: http://localhost:8080"
echo ""
echo "3. Login credentials:"
echo "   Username: admin"
echo "   Password: (run the command below)"
echo ""
echo "   kubectl get secret prometheus-grafana -n monitoring -o jsonpath=\"{.data.admin-password}\" | base64 --decode && echo"
echo ""
echo "To access Prometheus:"
echo "--------------------------------------"
echo "1. Port-forward the Prometheus service:"
echo "   kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring"
echo ""
echo "2. Open your browser to: http://localhost:9090"
echo ""
