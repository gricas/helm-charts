#!/bin/bash

# Comprehensive Ingress Controller Test Script
# Tests ingress controller functionality and troubleshoots 404 errors

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TIMEOUT=120
TEST_NAMESPACE="ingress-test-infra"
INGRESS_NAMESPACE="ingress-nginx-infra"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "$1 command not found. Please install $1."
        exit 1
    fi
}

# Function to wait for resource to be ready
wait_for_resource() {
    local resource_type=$1
    local resource_name=$2
    local namespace=$3
    local condition=${4:-"ready"}
    local timeout=${5:-$TIMEOUT}

    log_info "Waiting for $resource_type/$resource_name to be $condition..."
    if ! kubectl wait --for=condition=$condition $resource_type/$resource_name -n $namespace --timeout=${timeout}s; then
        log_error "$resource_type/$resource_name failed to become $condition within ${timeout}s"
        return 1
    fi
    log_success "$resource_type/$resource_name is $condition"
}

# Function to test HTTP endpoint
test_endpoint() {
    local url=$1
    local expected_status=${2:-200}
    local description=${3:-"endpoint"}

    log_info "Testing $description: $url"

    # Test with curl
    local response=$(curl -s -w "%{http_code}" -o /tmp/curl_response.txt "$url" 2>/dev/null || echo "000")

    if [[ "$response" == "$expected_status" ]]; then
        log_success "$description responded with HTTP $response"
        if [[ -f /tmp/curl_response.txt ]]; then
            local content_preview=$(head -c 100 /tmp/curl_response.txt | tr '\n' ' ')
            log_info "Response preview: $content_preview..."
        fi
        return 0
    else
        log_error "$description responded with HTTP $response (expected $expected_status)"
        if [[ -f /tmp/curl_response.txt ]]; then
            log_error "Response content:"
            cat /tmp/curl_response.txt | head -20
        fi
        return 1
    fi
}

# Function to get service endpoint
get_service_endpoint() {
    local service_name=$1
    local namespace=$2
    local port=${3:-80}

    local cluster_ip=$(kubectl get service $service_name -n $namespace -o jsonpath='{.spec.clusterIP}' 2>/dev/null || echo "")
    if [[ -n "$cluster_ip" && "$cluster_ip" != "None" ]]; then
        echo "http://$cluster_ip:$port"
    else
        echo ""
    fi
}

# Function to create test resources
create_test_resources() {
    log_info "Creating test namespace and resources..."

    kubectl create namespace $TEST_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

    cat <<EOF | kubectl apply -f -
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-echo-server
  namespace: $TEST_NAMESPACE
  labels:
    app: test-echo-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-echo-server
  template:
    metadata:
      labels:
        app: test-echo-server
    spec:
      containers:
      - name: echo-server
        image: mendhak/http-https-echo:latest
        ports:
        - containerPort: 8080
          name: http
        env:
        - name: HTTP_PORT
          value: "8080"
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 20

---
apiVersion: v1
kind: Service
metadata:
  name: test-echo-service
  namespace: $TEST_NAMESPACE
spec:
  selector:
    app: test-echo-server
  ports:
  - name: http
    port: 80
    targetPort: 8080
    protocol: TCP
  type: ClusterIP

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-echo-ingress
  namespace: $TEST_NAMESPACE
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
spec:
  ingressClassName: nginx
  rules:
  - host: test-ingress.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: test-echo-service
            port:
              number: 80
EOF

    # Wait for deployment to be ready
    wait_for_resource "deployment" "test-echo-server" "$TEST_NAMESPACE" "available"
}

# Function to cleanup test resources
cleanup_test_resources() {
    log_info "Cleaning up test resources..."
    kubectl delete namespace $TEST_NAMESPACE --ignore-not-found=true --timeout=60s
    log_success "Test resources cleaned up"
}

# Function to check ingress controller status
check_ingress_controller() {
    log_info "=== Checking Ingress Controller Status ==="

    # Check if ingress-nginx namespace exists
    if ! kubectl get namespace $INGRESS_NAMESPACE &>/dev/null; then
        log_error "Ingress-nginx namespace '$INGRESS_NAMESPACE' not found"
        return 1
    fi

    # Check controller pods
    local controller_pods=$(kubectl get pods -n $INGRESS_NAMESPACE -l app.kubernetes.io/component=controller --no-headers 2>/dev/null | wc -l)
    if [[ $controller_pods -eq 0 ]]; then
        log_error "No ingress controller pods found in namespace $INGRESS_NAMESPACE"
        return 1
    fi
    log_success "Found $controller_pods ingress controller pod(s)"

    # Check pod status
    kubectl get pods -n $INGRESS_NAMESPACE -l app.kubernetes.io/component=controller

    # Check if all pods are ready
    local ready_pods=$(kubectl get pods -n $INGRESS_NAMESPACE -l app.kubernetes.io/component=controller --no-headers | awk '$2~/^1\/1/ {count++} END {print count+0}')
    if [[ $ready_pods -ne $controller_pods ]]; then
        log_warning "Not all controller pods are ready ($ready_pods/$controller_pods)"
        kubectl describe pods -n $INGRESS_NAMESPACE -l app.kubernetes.io/component=controller
    else
        log_success "All ingress controller pods are ready"
    fi

    # Check controller service
    if kubectl get service -n $INGRESS_NAMESPACE ingress-nginx-controller &>/dev/null; then
        log_success "Ingress controller service found"
        kubectl get service -n $INGRESS_NAMESPACE ingress-nginx-controller
    else
        log_warning "Ingress controller service not found"
    fi

    # Check ingress class
    if kubectl get ingressclass nginx &>/dev/null; then
        log_success "Nginx ingress class found"
        kubectl get ingressclass nginx -o yaml
    else
        log_error "Nginx ingress class not found"
        log_info "Available ingress classes:"
        kubectl get ingressclass
    fi
}

# Function to test existing ingresses
test_existing_ingresses() {
    log_info "=== Testing Existing Ingresses ==="

    # Get all ingresses
    local ingresses=$(kubectl get ingress -A --no-headers 2>/dev/null)
    if [[ -z "$ingresses" ]]; then
        log_warning "No existing ingresses found"
        return 0
    fi

    echo "$ingresses" | while read namespace name class hosts address ports age; do
        log_info "Testing ingress: $namespace/$name"
        log_info "  Hosts: $hosts"
        log_info "  Class: $class"

        # Get ingress details
        local ingress_yaml=$(kubectl get ingress $name -n $namespace -o yaml)

        # Check if backend services exist
        local services=$(echo "$ingress_yaml" | grep -A2 "service:" | grep "name:" | awk '{print $2}' | sort -u)
        for service in $services; do
            if kubectl get service $service -n $namespace &>/dev/null; then
                log_success "  Backend service '$service' exists"

                # Test service endpoint directly
                local service_endpoint=$(get_service_endpoint "$service" "$namespace")
                if [[ -n "$service_endpoint" ]]; then
                    log_info "  Testing backend service directly: $service_endpoint"
                    if test_endpoint "$service_endpoint" 200 "Backend service $service"; then
                        log_success "  Backend service $service is responding correctly"
                    else
                        log_error "  Backend service $service is not responding correctly"
                        # Get service details
                        kubectl describe service $service -n $namespace
                        # Check endpoints
                        kubectl get endpoints $service -n $namespace
                    fi
                fi
            else
                log_error "  Backend service '$service' not found in namespace $namespace"
            fi
        done

        # Test ingress via controller service (internal cluster test)
        if kubectl get service -n $INGRESS_NAMESPACE ingress-nginx-controller &>/dev/null; then
            local controller_ip=$(kubectl get service -n $INGRESS_NAMESPACE ingress-nginx-controller -o jsonpath='{.spec.clusterIP}')
            if [[ -n "$controller_ip" ]]; then
                # Extract first host from hosts field
                local first_host=$(echo "$hosts" | cut -d',' -f1)
                if [[ "$first_host" != "<none>" && -n "$first_host" ]]; then
                    local test_url="http://$controller_ip"
                    log_info "  Testing ingress via controller: $test_url (Host: $first_host)"

                    # Create a test pod to curl from inside cluster
                    kubectl run curl-test-$RANDOM --image=curlimages/curl --rm -i --restart=Never --timeout=30s -- \
                        curl -s -w "%{http_code}" -H "Host: $first_host" "$test_url" > /tmp/ingress_test.out 2>&1 || true

                    if [[ -f /tmp/ingress_test.out ]]; then
                        local response=$(cat /tmp/ingress_test.out | tail -3 | head -1 2>/dev/null || echo "failed")
                        if [[ "$response" =~ ^[0-9]{3}$ ]]; then
                            if [[ "$response" == "200" ]]; then
                                log_success "  Ingress responding with HTTP $response"
                            elif [[ "$response" == "404" ]]; then
                                log_error "  Ingress responding with HTTP 404 - routing issue!"
                            else
                                log_warning "  Ingress responding with HTTP $response"
                            fi
                        else
                            log_error "  Failed to test ingress via controller"
                        fi
                    fi
                fi
            fi
        fi

        echo ""
    done
}

# Function to test ingress with our test application
test_ingress_functionality() {
    log_info "=== Testing Ingress Functionality ==="

    create_test_resources

    # Test ingress via controller service
    if kubectl get service -n $INGRESS_NAMESPACE ingress-nginx-controller &>/dev/null; then
        local controller_ip=$(kubectl get service -n $INGRESS_NAMESPACE ingress-nginx-controller -o jsonpath='{.spec.clusterIP}')
        if [[ -n "$controller_ip" ]]; then
            log_info "Testing via ingress controller service: $controller_ip"

            # Test with different Host headers
            for host in "test-ingress.local" "test.example.com"; do
                log_info "Testing with Host: $host"

                # Create curl test pod
                kubectl run curl-test-$RANDOM --image=curlimages/curl --rm -i --restart=Never --timeout=30s -- \
                    curl -v -H "Host: $host" "http://$controller_ip" > /tmp/curl_test_$host.out 2>&1 || true

                if [[ -f "/tmp/curl_test_$host.out" ]]; then
                    local http_code=$(grep "< HTTP/" "/tmp/curl_test_$host.out" | awk '{print $3}' | head -1)
                    if [[ "$http_code" == "200" ]]; then
                        log_success "Host $host: HTTP 200 - Working correctly"
                    elif [[ "$http_code" == "404" ]]; then
                        log_error "Host $host: HTTP 404 - Ingress routing failed"
                        log_error "Curl output:"
                        cat "/tmp/curl_test_$host.out"
                    else
                        log_warning "Host $host: HTTP $http_code"
                        cat "/tmp/curl_test_$host.out"
                    fi
                fi
            done
        fi
    fi

    cleanup_test_resources
}

# Function to diagnose 404 issues
diagnose_404_issues() {
    log_info "=== Diagnosing 404 Issues ==="

    # Check ingress controller logs
    log_info "Checking ingress controller logs for errors..."
    kubectl logs -n $INGRESS_NAMESPACE -l app.kubernetes.io/component=controller --tail=50 | grep -E "(ERROR|WARN|404|error|warn)" || log_info "No recent errors found in logs"

    # Check ingress controller configuration
    log_info "Checking ingress controller configuration..."
    kubectl get configmap -n $INGRESS_NAMESPACE nginx-configuration -o yaml 2>/dev/null || log_warning "No nginx-configuration configmap found"

    # Check if ingress controller can reach backends
    log_info "Checking ingress controller connectivity to backends..."

    # Get all ingresses and their backends
    kubectl get ingress -A -o jsonpath='{range .items[*]}{.metadata.namespace}{" "}{.metadata.name}{" "}{.spec.rules[*].http.paths[*].backend.service.name}{"\n"}{end}' | \
    while read namespace ingress_name service_name; do
        if [[ -n "$service_name" && "$service_name" != "<no value>" ]]; then
            log_info "Checking connectivity to $namespace/$service_name..."

            # Check if service exists
            if kubectl get service $service_name -n $namespace &>/dev/null; then
                # Check service endpoints
                local endpoints=$(kubectl get endpoints $service_name -n $namespace -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null)
                if [[ -n "$endpoints" ]]; then
                    log_success "Service $namespace/$service_name has endpoints: $endpoints"
                else
                    log_error "Service $namespace/$service_name has no endpoints - check pod selectors and readiness"
                    kubectl describe service $service_name -n $namespace
                    kubectl get pods -n $namespace -l $(kubectl get service $service_name -n $namespace -o jsonpath='{.spec.selector}' | sed 's/map\[//;s/\]//;s/ /,/g;s/:=/=/g') 2>/dev/null || log_warning "Could not find pods for service selector"
                fi
            else
                log_error "Service $namespace/$service_name does not exist"
            fi
        fi
    done

    # Check DNS resolution
    log_info "Testing DNS resolution..."
    kubectl run dns-test --image=busybox --rm -i --restart=Never --timeout=30s -- nslookup kubernetes.default.svc.cluster.local > /tmp/dns_test.out 2>&1 || true
    if grep -q "Address" /tmp/dns_test.out; then
        log_success "DNS resolution working"
    else
        log_error "DNS resolution issues detected"
        cat /tmp/dns_test.out
    fi
}

# Function to provide troubleshooting recommendations
provide_recommendations() {
    log_info "=== Troubleshooting Recommendations ==="

    echo ""
    log_info "Common 404 causes and solutions:"
    echo "1. Incorrect ingress configuration:"
    echo "   - Check host names match exactly"
    echo "   - Verify path matching (Prefix vs Exact)"
    echo "   - Ensure correct service name and port"
    echo ""
    echo "2. Backend service issues:"
    echo "   - Service doesn't exist or wrong namespace"
    echo "   - No endpoints (pods not ready or selector mismatch)"
    echo "   - Pod/container not listening on expected port"
    echo ""
    echo "3. Ingress controller issues:"
    echo "   - Controller not running or not ready"
    echo "   - Wrong ingress class or class not found"
    echo "   - Controller can't reach backend services"
    echo ""
    echo "4. Network policies blocking traffic"
    echo ""
    echo "Commands to investigate further:"
    echo "kubectl get ingress -A"
    echo "kubectl describe ingress <ingress-name> -n <namespace>"
    echo "kubectl get endpoints <service-name> -n <namespace>"
    echo "kubectl logs -n $INGRESS_NAMESPACE -l app.kubernetes.io/component=controller"
    echo "kubectl exec -n $INGRESS_NAMESPACE <controller-pod> -- nginx -T"
    echo ""
}

# Main function
main() {
    log_info "=== Ingress Controller Comprehensive Test ==="
    echo ""

    # Check prerequisites
    check_command kubectl
    check_command curl

    # Run tests
    check_ingress_controller
    echo ""

    test_existing_ingresses
    echo ""

    test_ingress_functionality
    echo ""

    diagnose_404_issues
    echo ""

    provide_recommendations

    log_success "Ingress controller test completed!"
}

# Cleanup function for script interruption
cleanup() {
    log_warning "Script interrupted, cleaning up..."
    cleanup_test_resources 2>/dev/null || true
    exit 1
}

# Set trap for cleanup
trap cleanup INT TERM

# Help function
show_help() {
    echo "Ingress Controller Test Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -n, --namespace NAME    Ingress controller namespace (default: ingress-nginx)"
    echo "  -t, --timeout SECONDS   Timeout for operations (default: 120)"
    echo "  --cleanup-only          Only cleanup test resources and exit"
    echo "  --test-only             Only run functionality test (skip existing ingress tests)"
    echo ""
    echo "Examples:"
    echo "  $0                      Run full test suite"
    echo "  $0 -n nginx-ingress    Test with custom namespace"
    echo "  $0 --cleanup-only       Cleanup test resources"
    echo ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -n|--namespace)
            INGRESS_NAMESPACE="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --cleanup-only)
            cleanup_test_resources
            exit 0
            ;;
        --test-only)
            TEST_ONLY=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main function
if [[ "$TEST_ONLY" == "true" ]]; then
    test_ingress_functionality
else
    main
fi
