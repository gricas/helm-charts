#!/bin/bash

# Quick fix for PATH issues with Go and chart-testing
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_status "Fixing PATH for Go and chart-testing..."

# Add Go to PATH if not already there
if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    print_status "Added Go to PATH in ~/.bashrc"
fi

# Add Go bin to PATH if not already there
if ! grep -q "$HOME/go/bin" ~/.bashrc; then
    echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
    print_status "Added Go bin to PATH in ~/.bashrc"
fi

# Source bashrc
source ~/.bashrc 2>/dev/null || true

# Export for current session
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

print_status "PATH fixed! Testing installations..."

# Test Go
if command -v go &> /dev/null; then
    print_status "✅ Go is working: $(go version)"
else
    print_warning "❌ Go not found in PATH"
fi

# Test chart-testing
if command -v ct &> /dev/null; then
    print_status "✅ Chart-testing is working: $(ct version)"
else
    print_warning "❌ Chart-testing not found in PATH"
fi

print_status "If tools are still not found, please restart your terminal or run: source ~/.bashrc"
