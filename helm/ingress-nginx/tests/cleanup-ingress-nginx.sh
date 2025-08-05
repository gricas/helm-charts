#!/bin/bash

# Ingress-NGINX Cleanup Script
# This script removes ingress-nginx resources that may have been deployed incorrectly
# across multiple namespaces (default and ingress-nginx)

set -e

echo "🔍 Starting ingress-nginx cleanup process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if resource exists
resource_exists() {
    kubectl get "$1" "$2" -n "$3" &>/dev/null
}

# Function to safely delete resource
safe_delete() {
    local resource_type="$1"
    local resource_name="$2"
    local namespace="$3"
    
    if resource_exists "$resource_type" "$resource_name" "$namespace"; then
        echo -e "${YELLOW}Deleting $resource_type/$resource_name in namespace $namespace${NC}"
        kubectl delete "$resource_type" "$resource_name" -n "$namespace" --ignore-not-found=true
    else
        echo -e "${GREEN}✓ $resource_type/$resource_name not found in namespace $namespace${NC}"
    fi
}

echo "📋 Checking for ingress-nginx Helm releases..."
HELM_RELEASES=$(helm list -A -q | grep -i ingress || true)

if [ -n "$HELM_RELEASES" ]; then
    echo -e "${YELLOW}Found Helm releases related to ingress:${NC}"
    helm list -A | grep -i ingress || true
    echo ""
    read -p "Do you want to uninstall these Helm releases? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$HELM_RELEASES" | while read -r release; do
            if [ -n "$release" ]; then
                echo "Uninstalling Helm release: $release"
                helm uninstall "$release" || true
            fi
        done
    fi
fi

echo ""
echo "🗑️  Cleaning up ingress-nginx resources in default namespace..."

# Clean up common ingress-nginx resources in default namespace
RESOURCES_DEFAULT=(
    "deployment/ingress-nginx-controller"
    "service/ingress-nginx-controller"
    "service/ingress-nginx-controller-admission"
    "service/ingress-nginx-controller-metrics"
    "configmap/ingress-nginx-controller"
    "serviceaccount/ingress-nginx"
    "serviceaccount/ingress-nginx-admission"
    "role/ingress-nginx"
    "role/ingress-nginx-admission"
    "rolebinding/ingress-nginx"
    "rolebinding/ingress-nginx-admission"
    "job/ingress-nginx-admission-create"
    "job/ingress-nginx-admission-patch"
)

for resource in "${RESOURCES_DEFAULT[@]}"; do
    IFS='/' read -r type name <<< "$resource"
    safe_delete "$type" "$name" "default"
done

echo ""
echo "🗑️  Cleaning up ingress-nginx resources in ingress-nginx namespace..."

# Check if ingress-nginx namespace exists
if kubectl get namespace ingress-nginx &>/dev/null; then
    # Clean up all resources in ingress-nginx namespace
    echo -e "${YELLOW}Deleting all resources in ingress-nginx namespace${NC}"
    kubectl delete all --all -n ingress-nginx --ignore-not-found=true
    
    # Clean up other resource types
    kubectl delete configmaps --all -n ingress-nginx --ignore-not-found=true
    kubectl delete secrets --all -n ingress-nginx --ignore-not-found=true
    kubectl delete serviceaccounts --all -n ingress-nginx --ignore-not-found=true
    kubectl delete roles --all -n ingress-nginx --ignore-not-found=true
    kubectl delete rolebindings --all -n ingress-nginx --ignore-not-found=true
    
    # Delete the namespace itself
    echo -e "${YELLOW}Deleting ingress-nginx namespace${NC}"
    kubectl delete namespace ingress-nginx --ignore-not-found=true
else
    echo -e "${GREEN}✓ ingress-nginx namespace does not exist${NC}"
fi

echo ""
echo "🗑️  Cleaning up cluster-wide ingress-nginx resources..."

# Clean up cluster-wide resources
CLUSTER_RESOURCES=(
    "clusterrole/ingress-nginx"
    "clusterrole/ingress-nginx-admission"
    "clusterrolebinding/ingress-nginx"
    "clusterrolebinding/ingress-nginx-admission"
    "ingressclass/nginx"
    "validatingwebhookconfiguration/ingress-nginx-admission"
    "mutatingwebhookconfiguration/ingress-nginx-admission"
)

for resource in "${CLUSTER_RESOURCES[@]}"; do
    IFS='/' read -r type name <<< "$resource"
    if kubectl get "$type" "$name" &>/dev/null; then
        echo -e "${YELLOW}Deleting cluster resource: $type/$name${NC}"
        kubectl delete "$type" "$name" --ignore-not-found=true
    else
        echo -e "${GREEN}✓ Cluster resource $type/$name not found${NC}"
    fi
done

echo ""
echo "🔍 Checking for remaining ingress-nginx resources..."

# Check for any remaining resources
echo "Remaining ingress-related resources:"
kubectl get all,ing,ingressclass -A | grep -i ingress || echo "No remaining ingress-nginx resources found"

echo ""
echo -e "${GREEN}✅ Ingress-nginx cleanup completed!${NC}"
echo ""
echo "📝 Next steps:"
echo "1. Verify no orphaned resources remain: kubectl get all,ing,ingressclass -A | grep -i nginx"
echo "2. If you want to reinstall ingress-nginx properly, use:"
echo "   helm install ingress-nginx ./ingress-nginx/ -n ingress-nginx --create-namespace"
echo "3. Update your Ingress resources to use the correct ingress class if needed"