#!/bin/bash

# Exit on error
set -e

echo "📦 Step 1: Checking if kubectl is installed..."
if ! command -v kubectl &> /dev/null
then
    echo "❌ kubectl not found. Please install kubectl before running this script."
    exit 1
fi

echo "🔧 Step 2: Creating Argo CD namespace..."
kubectl create namespace argocd || echo "✅ Namespace 'argocd' already exists"

echo "🚀 Step 3: Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Step 4: Waiting for Argo CD server to be ready..."
kubectl wait deployment argocd-server -n argocd --for=condition=Available=True --timeout=180s

echo "🔐 Step 5: Fetching initial admin password..."
ADMIN_PWD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)

echo -e "\n✅ Argo CD is installed successfully."
echo "🌐 Access it at: http://localhost:8080"
echo "🔑 Username: admin"
echo "🔑 Password: $ADMIN_PWD"

echo -e "\n📡 Step 6: Starting port-forwarding..."
echo "➡️  Press Ctrl+C to stop"
kubectl port-forward svc/argocd-server -n argocd 8080:443
