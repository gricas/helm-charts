# Development Setup Guide

This guide helps you set up the development environment for the Helm charts repository.

## Prerequisites

- Linux/macOS system
- sudo access
- curl and tar installed

## Quick Setup

### 1. Install Development Tools

Use the provided script to install all required tools:

```bash
# Install all tools at once
./scripts/install-tools.sh all

# Or install individually
./scripts/install-tools.sh go
./scripts/install-tools.sh ct
./scripts/install-tools.sh helm
```

### 2. Setup Pre-commit Hooks

```bash
# Install pre-commit
pip install pre-commit

# Install the git hook scripts
pre-commit install

# Run against all files (optional)
pre-commit run --all-files
```

## Manual Installation

If the script doesn't work, here are manual installation steps:

### Install Go

```bash
# For ARM64 (Raspberry Pi, Apple Silicon, etc.)
curl -L https://go.dev/dl/go1.24.6.linux-arm64.tar.gz | sudo tar -C /usr/local -xzf -

# For AMD64 (Intel/AMD)
curl -L https://go.dev/dl/go1.24.6.linux-amd64.tar.gz | sudo tar -C /usr/local -xzf -

# Add to PATH
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

# Verify installation
go version
```

### Install Chart-Testing

**Option 1: Using Go (Recommended for ARM64)**

```bash
# Install Go first (see above)
go install github.com/helm/chart-testing/v3/ct@latest

# Add to PATH if not already there
if ! grep -q "$HOME/go/bin" ~/.bashrc; then
    echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
    source ~/.bashrc
fi

# Verify installation
ct version
```

**Option 2: Direct Download (AMD64 only)**

```bash
# Get latest version
CT_VERSION=$(curl -s https://api.github.com/repos/helm/chart-testing/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
CT_VERSION_NUM=$(echo "$CT_VERSION" | sed 's/^v//')

# Download and install (AMD64 only)
curl -L "https://github.com/helm/chart-testing/releases/download/${CT_VERSION}/chart-testing_${CT_VERSION_NUM}_linux-amd64.tar.gz" | tar xz
sudo mv ct /usr/local/bin/ct

# Verify installation
ct version
```

**Note**: ARM64 users should use Option 1 (Go installation) as the ARM64 binary may not be publicly available.

### Install Helm

```bash
# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    ARCH_SUFFIX="linux-arm64"
elif [ "$ARCH" = "x86_64" ]; then
    ARCH_SUFFIX="linux-amd64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Download and install Helm
curl https://get.helm.sh/helm-v3.18.4-${ARCH_SUFFIX}.tar.gz | tar xz
sudo mv ${ARCH_SUFFIX}/helm /usr/local/bin/helm
rm -rf ${ARCH_SUFFIX}

# Verify installation
helm version
```

## Troubleshooting

### PATH Issues

If you get "command not found" errors after installation:

```bash
# Quick fix for PATH issues
./scripts/fix-path.sh

# Or manually add to PATH
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
source ~/.bashrc
```

### Common Download Issues

#### "gzip: stdin: not in gzip format"

This error usually means:
1. **Wrong URL**: The download URL has changed
2. **Network issues**: Download was interrupted
3. **Rate limiting**: GitHub API limits exceeded

**Solutions:**
- Check the URL is correct
- Try downloading manually first
- Use the provided script which includes verification
- Wait a few minutes and retry

#### "tar: Child returned status 1"

This often means:
1. **Corrupted download**: File is incomplete
2. **Wrong architecture**: Downloaded wrong version
3. **Permission issues**: Can't extract to target directory

**Solutions:**
- Verify file size after download
- Check you're downloading the right architecture
- Ensure you have write permissions

### Pre-commit Issues

#### "pre-commit: command not found"

```bash
# Install pre-commit
pip install pre-commit

# Or using pip3
pip3 install pre-commit
```

#### Helm linting fails

```bash
# Ensure Helm is installed and in PATH
helm version

# Check chart syntax
helm lint helm/your-chart/

# Update dependencies
helm dependency update helm/your-chart/
```

### GitHub Actions Issues

#### Chart-testing download fails

The workflow now uses the correct URL format:
- ✅ `chart-testing_3.13.0_linux_amd64.tar.gz`
- ❌ `ct_linux_amd64.tar.gz` (old format)

#### Go installation fails

The script includes proper error handling and verification:
- Downloads to temp directory first
- Verifies file size and integrity
- Provides clear error messages

## Development Workflow

### 1. Make Changes

```bash
# Create a new branch
git checkout -b feature/new-chart

# Make your changes
# ...

# Test locally
helm lint helm/your-chart/
helm template test-release helm/your-chart/ --debug --dry-run
```

### 2. Run Pre-commit

```bash
# Run pre-commit hooks
pre-commit run

# Or run specific hook
pre-commit run helmlint
```

### 3. Test with Chart-Testing

```bash
# Test all charts
ct lint --all --config .github/ct.yaml

# Test specific chart
ct lint --charts helm/your-chart/ --config .github/ct.yaml
```

### 4. Commit and Push

```bash
git add .
git commit -m "Add new chart"
git push origin feature/new-chart
```

## Pre-commit Hooks

The repository includes the following pre-commit hooks:

- **end-of-file-fixer**: Ensures files end with newline
- **trailing-whitespace**: Removes trailing whitespace
- **helmlint**: Lints Helm charts
- **helm-docs**: Generates documentation

### Customizing Hooks

Edit `.pre-commit-config.yaml` to:
- Add new hooks
- Modify existing hooks
- Change hook versions

## CI/CD Integration

The GitHub Actions workflows use the same tools and configurations:

- **setup-environment.yml**: Sets up Helm and chart-testing
- **validate-chart.yml**: Validates individual charts
- **test-charts-ct.yml**: Runs chart-testing

### Local Testing

Test the same workflows locally:

```bash
# Test environment setup
./scripts/install-tools.sh all

# Test chart validation
ct lint --all --config .github/ct.yaml

# Test chart installation
ct install --all --config .github/ct.yaml
```

## Support

For issues:
1. Check this troubleshooting guide
2. Review GitHub Actions logs
3. Test locally with the provided scripts
4. Check the main README.md for additional information
