#!/bin/bash

# Script to install common development tools with proper error handling
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to download and verify file
download_and_verify() {
    local url="$1"
    local output_file="$2"
    local expected_size="$3"

    print_status "Downloading from: $url"

    # Download with progress
    if curl -L -o "$output_file" "$url"; then
        # Check file size
        local actual_size=$(stat -c%s "$output_file" 2>/dev/null || stat -f%z "$output_file" 2>/dev/null)
        if [ "$actual_size" -lt "$expected_size" ]; then
            print_error "Downloaded file is too small ($actual_size bytes). Expected at least $expected_size bytes."
            return 1
        fi

        # Check if it's a valid archive
        if [[ "$output_file" == *.tar.gz ]]; then
            if ! tar -tzf "$output_file" >/dev/null 2>&1; then
                print_error "Downloaded file is not a valid tar.gz archive"
                return 1
            fi
        fi

        print_status "Download successful and verified"
        return 0
    else
        print_error "Download failed"
        return 1
    fi
}

# Detect system architecture
detect_arch() {
    local arch=$(uname -m)
    case "$arch" in
        "x86_64")
            echo "linux-amd64"
            ;;
        "aarch64"|"arm64")
            echo "linux-arm64"
            ;;
        "armv7l")
            echo "linux-armv6l"
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
}

# Install Go
install_go() {
    local version="${1:-1.24.6}"
    local arch="${2:-$(detect_arch)}"

    print_status "Installing Go $version for $arch"

    # Create temp directory
    local temp_dir=$(mktemp -d)
    local go_file="$temp_dir/go$version.$arch.tar.gz"

    # Download Go
    local go_url="https://go.dev/dl/go$version.$arch.tar.gz"

    # Set expected size based on architecture
    local expected_size
    if [[ "$arch" == *"arm64"* ]]; then
        expected_size=70000000  # ~70MB for ARM64
    else
        expected_size=100000000  # ~100MB for AMD64
    fi

    if download_and_verify "$go_url" "$go_file" "$expected_size"; then
        # Install Go
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf "$go_file"

        # Add to PATH if not already there
        if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
            echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
            print_status "Added Go to PATH in ~/.bashrc"
        fi

        # Source bashrc to make go available immediately
        source ~/.bashrc 2>/dev/null || true

        print_status "Go installation completed successfully"
        /usr/local/go/bin/go version
    else
        print_error "Go installation failed"
        return 1
    fi

    # Cleanup
    rm -rf "$temp_dir"
}

# Install chart-testing
install_chart_testing() {
    print_status "Installing chart-testing"

    # Check if Go is installed
    if ! command -v go &> /dev/null; then
        print_error "Go is required for chart-testing installation. Please install Go first."
        return 1
    fi

    # Use Go to install chart-testing (works on all architectures)
    print_status "Installing chart-testing using Go"

    if go install github.com/helm/chart-testing/v3/ct@latest; then
        # Add to PATH if not already there
        if ! grep -q "$HOME/go/bin" ~/.bashrc; then
            echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
            print_status "Added Go bin to PATH in ~/.bashrc"
        fi

        # Source bashrc to make ct available immediately
        source ~/.bashrc 2>/dev/null || true
        export PATH=$PATH:$HOME/go/bin

        print_status "Chart-testing installation completed successfully"
        ct version
    else
        print_error "Chart-testing installation failed"
        return 1
    fi
}

# Install Helm
install_helm() {
    local version="${1:-3.18.4}"
    local arch=$(detect_arch)

    print_status "Installing Helm $version for $arch"

    # Download and install Helm
    curl https://get.helm.sh/helm-v${version}-${arch}.tar.gz | tar xz
    sudo mv ${arch}/helm /usr/local/bin/helm
    rm -rf ${arch}

    print_status "Helm installation completed successfully"
    helm version
}

# Main function
main() {
    local tool="$1"

    case "$tool" in
        "go")
            install_go "${2:-1.24.6}" "${3:-$(detect_arch)}"
            ;;
        "ct"|"chart-testing")
            install_chart_testing
            ;;
        "helm")
            install_helm "${2:-3.18.4}"
            ;;
        "all")
            install_go
            install_chart_testing
            install_helm
            ;;
        *)
            print_error "Unknown tool: $tool"
            echo "Usage: $0 {go|ct|helm|all} [version] [arch]"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
