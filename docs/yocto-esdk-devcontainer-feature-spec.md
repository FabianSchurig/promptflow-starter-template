# Yocto eSDK Devcontainer Feature Specification

## Issue Summary

Create a minimal devcontainer feature for setting up Yocto Extensible SDK (eSDK) and IDE-SDK in development containers. The feature should be configurable, maintainable, and support multiple eSDKs from different distributions.

**Target Repository**: FabianSchurig/devcontainer-features

---

## Background: Yocto eSDK Architecture

### What is Yocto eSDK?

The Yocto Extensible SDK (eSDK) is an advanced development kit for cross-platform embedded application development. Unlike a traditional SDK, the eSDK is extensible and updateable, making it ideal for modern embedded Linux development workflows.

### Key Components

1. **Cross-development Toolchain**: Compilers, linkers, and build tools for target architecture
2. **Sysroots**: Directory trees containing libraries and headers matched to target image
3. **devtool Utility**: Central tool for managing recipes, adding applications, and modifying components
4. **Environment Setup Script**: Configures PATH, toolchain variables, and development environment
5. **Minimal Build System**: Allows building and extending packages without full Yocto build

### eSDK vs Standard SDK

| Feature | Standard SDK | Extensible SDK (eSDK) |
|---------|--------------|----------------------|
| Cross-compilation | ✅ Yes | ✅ Yes |
| Fixed sysroot | ✅ Yes | ✅ Yes |
| Updateable | ❌ No | ✅ Yes |
| Add new packages | ❌ No | ✅ Yes (via devtool) |
| Modify recipes | ❌ No | ✅ Yes (via devtool) |
| Team collaboration | Limited | ✅ Excellent |

### Typical Usage Workflow

\`\`\`bash
# 1. Install the eSDK
bash poky-glibc-x86_64-myimage-cortexa7t2hf-toolchain-ext-3.1.3.sh

# 2. Source the environment
source ~/poky_sdk/environment-setup-cortexa7t2hf-neon-vfpv4-poky-linux-gnueabi

# 3. Develop with devtool
devtool add myapp https://github.com/example/myapp.git
devtool build myapp
devtool deploy-target myapp root@target-ip
\`\`\`

---

## Feature Requirements

### Core Functionality

1. **SDK Installation**
   - Download eSDK installer script from configurable repository
   - Execute installer with appropriate options
   - Handle different SDK naming conventions
   - Support verification (checksums/signatures)

2. **Environment Configuration**
   - Automatically source environment setup script
   - Make toolchain available in container PATH
   - Configure IDE integration points
   - Support persistent environment across container rebuilds

3. **Multi-SDK Support**
   - Install multiple eSDKs for different target architectures
   - Support different Yocto distributions (Poky, custom layers)
   - Handle version conflicts gracefully
   - Allow selective activation of specific SDK

### Configuration Options

The devcontainer feature should accept the following options:

\`\`\`json
{
  "features": {
    "ghcr.io/fabianschurig/devcontainer-features/yocto-esdk:1": {
      "repositoryUrl": "https://artifactory.company.com/yocto-sdk",
      "installerName": "poky-glibc-x86_64-core-image-minimal-armv8a-toolchain-ext-5.0.3.sh",
      "checksumUrl": "https://artifactory.company.com/yocto-sdk/checksums.sha256",
      "installPath": "/opt/yocto-sdk",
      "autoSource": true,
      "username": "",
      "password": ""
    }
  }
}
\`\`\`

#### Option Details

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| \`repositoryUrl\` | string | *required* | Base URL of repository (Artifactory, Nexus, HTTP server) |
| \`installerName\` | string | *required* | Name of the eSDK installer script (.sh file) |
| \`checksumUrl\` | string | "" | URL to checksum file for verification |
| \`installPath\` | string | "/opt/yocto-sdk" | Installation directory for SDK |
| \`autoSource\` | boolean | true | Automatically source environment in shell sessions |
| \`username\` | string | "" | Username for authenticated repositories |
| \`password\` | string | "" | Password/token for authenticated repositories (use secrets) |
| \`version\` | string | "latest" | SDK version tag for tracking |
| \`verifyChecksum\` | boolean | true | Verify installer integrity before installation |

### Advanced Multi-SDK Configuration

For projects requiring multiple SDKs:

\`\`\`json
{
  "features": {
    "ghcr.io/fabianschurig/devcontainer-features/yocto-esdk:1": {
      "sdks": [
        {
          "name": "armv8a",
          "repositoryUrl": "https://artifactory.company.com/yocto-sdk",
          "installerName": "poky-glibc-x86_64-core-image-minimal-armv8a-toolchain-ext-5.0.3.sh",
          "installPath": "/opt/yocto-sdk/armv8a"
        },
        {
          "name": "cortexa7",
          "repositoryUrl": "https://artifactory.company.com/yocto-sdk",
          "installerName": "poky-glibc-x86_64-core-image-minimal-cortexa7t2hf-toolchain-ext-5.0.3.sh",
          "installPath": "/opt/yocto-sdk/cortexa7"
        }
      ],
      "defaultSdk": "armv8a"
    }
  }
}
\`\`\`

---

## Design Approach

### Minimal Boilerplate Philosophy

1. **Single Responsibility**: Feature only handles SDK installation and environment setup
2. **No Build System**: Don't recreate Yocto build infrastructure
3. **Use Existing Tools**: Leverage eSDK's own installation mechanisms
4. **Configuration Over Code**: Use declarative configuration, minimal scripting

### Installation Script Structure

\`\`\`bash
#!/usr/bin/env bash
set -e

# Parse options from environment variables
REPOSITORY_URL="\${REPOSITORYURL}"
INSTALLER_NAME="\${INSTALLERNAME}"
CHECKSUM_URL="\${CHECKSUMURL}"
INSTALL_PATH="\${INSTALLPATH:-/opt/yocto-sdk}"
AUTO_SOURCE="\${AUTOSOURCE:-true}"
USERNAME="\${USERNAME}"
PASSWORD="\${PASSWORD}"

# Download installer
download_installer() {
    local url="\${REPOSITORY_URL}/\${INSTALLER_NAME}"
    local installer_path="/tmp/\${INSTALLER_NAME}"
    
    if [ -n "\$USERNAME" ] && [ -n "\$PASSWORD" ]; then
        curl -u "\${USERNAME}:\${PASSWORD}" -fsSL "\$url" -o "\$installer_path"
    else
        curl -fsSL "\$url" -o "\$installer_path"
    fi
    
    echo "\$installer_path"
}

# Verify checksum
verify_installer() {
    local installer_path="\$1"
    
    if [ -n "\$CHECKSUM_URL" ] && [ "\$VERIFYCHECKSUM" = "true" ]; then
        curl -fsSL "\$CHECKSUM_URL" -o /tmp/checksums.sha256
        cd /tmp
        sha256sum -c checksums.sha256 --ignore-missing
    fi
}

# Install SDK
install_sdk() {
    local installer_path="\$1"
    chmod +x "\$installer_path"
    "\$installer_path" -d "\$INSTALL_PATH" -y
}

# Setup auto-sourcing
setup_auto_source() {
    if [ "\$AUTO_SOURCE" = "true" ]; then
        local env_script=\$(find "\$INSTALL_PATH" -name "environment-setup-*" | head -n1)
        if [ -f "\$env_script" ]; then
            echo "source '\$env_script'" >> /etc/bash.bashrc
            echo "source '\$env_script'" >> /etc/zsh/zshrc 2>/dev/null || true
        fi
    fi
}

# Main execution
main() {
    echo "Installing Yocto eSDK..."
    local installer_path=\$(download_installer)
    verify_installer "\$installer_path"
    install_sdk "\$installer_path"
    setup_auto_source
    echo "Yocto eSDK installed successfully at \$INSTALL_PATH"
}

main
\`\`\`

### Multi-SDK Support Strategy

For supporting multiple SDKs:

1. **Separate Install Paths**: Each SDK gets its own directory
2. **SDK Selector Script**: Create helper script to activate specific SDK
3. **Environment Isolation**: Prevent environment variable conflicts
4. **Documentation**: Clear guidance on switching between SDKs

Example SDK selector:

\`\`\`bash
#!/usr/bin/env bash
# yocto-sdk-select.sh

SDK_NAME="\${1}"
SDK_BASE="/opt/yocto-sdk"

if [ -z "\$SDK_NAME" ]; then
    echo "Available SDKs:"
    ls -1 "\$SDK_BASE"
    exit 0
fi

ENV_SCRIPT=\$(find "\$SDK_BASE/\$SDK_NAME" -name "environment-setup-*" | head -n1)

if [ -f "\$ENV_SCRIPT" ]; then
    source "\$ENV_SCRIPT"
    echo "Activated SDK: \$SDK_NAME"
else
    echo "SDK not found: \$SDK_NAME"
    exit 1
fi
\`\`\`

---

## Repository Distribution Best Practices

### Artifactory/Nexus Setup

1. **Naming Convention**
   \`\`\`
   {distro}-{libc}-{build_arch}-{image}-{target_arch}-toolchain-ext-{version}.sh
   
   Example:
   poky-glibc-x86_64-core-image-minimal-armv8a-toolchain-ext-5.0.3.sh
   \`\`\`

2. **Directory Structure**
   \`\`\`
   yocto-sdk/
   ├── stable/
   │   ├── 5.0.3/
   │   │   ├── poky-glibc-x86_64-core-image-minimal-armv8a-toolchain-ext-5.0.3.sh
   │   │   └── checksums.sha256
   │   └── latest -> 5.0.3
   ├── dev/
   └── archives/
   \`\`\`

3. **Checksum File Format**
   \`\`\`
   # checksums.sha256
   a1b2c3d4... poky-glibc-x86_64-core-image-minimal-armv8a-toolchain-ext-5.0.3.sh
   e5f6g7h8... poky-glibc-x86_64-core-image-minimal-cortexa7t2hf-toolchain-ext-5.0.3.sh
   \`\`\`

4. **Access Control**
   - Use token-based authentication
   - Store credentials in devcontainer secrets
   - Implement role-based access for teams

### Security Considerations

1. **Credential Management**
   - Never hardcode credentials in devcontainer.json
   - Use GitHub Codespaces secrets or environment variables
   - Support multiple auth methods (token, username/password, certificate)

2. **Integrity Verification**
   - Always verify checksums when available
   - Support GPG signature verification
   - Fail installation on verification failures

3. **HTTPS Only**
   - Enforce HTTPS for all downloads
   - Validate SSL certificates
   - Warn on insecure connections

---

## Testing Strategy

### Test Scenarios

1. **Basic Installation**
   - Single SDK from public URL
   - Single SDK from authenticated repository
   - Installation with checksum verification

2. **Multi-SDK Setup**
   - Multiple SDKs with different architectures
   - SDK switching functionality
   - Environment isolation

3. **Error Handling**
   - Invalid repository URL
   - Authentication failures
   - Checksum mismatches
   - Disk space issues
   - Network failures

4. **IDE Integration**
   - VSCode C/C++ extension configuration
   - IntelliSense with SDK headers
   - Debugging setup

### Test Container

\`\`\`json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/fabianschurig/devcontainer-features/yocto-esdk:1": {
      "repositoryUrl": "https://test-server.example.com/sdk",
      "installerName": "test-toolchain-ext-1.0.0.sh",
      "installPath": "/opt/test-sdk",
      "autoSource": true
    }
  },
  "postCreateCommand": "which arm-poky-linux-gnueabi-gcc && arm-poky-linux-gnueabi-gcc --version"
}
\`\`\`

---

## Implementation Checklist

### Phase 1: Basic Feature (MVP)
- [ ] Set up feature repository structure
- [ ] Create devcontainer-feature.json with basic options
- [ ] Implement install.sh for single SDK
- [ ] Add checksum verification
- [ ] Test with public test SDK
- [ ] Document basic usage

### Phase 2: Authentication & Security
- [ ] Add authentication support (username/password)
- [ ] Add token-based authentication
- [ ] Implement SSL certificate validation
- [ ] Add security documentation

### Phase 3: Multi-SDK Support
- [ ] Extend options schema for multiple SDKs
- [ ] Implement SDK selector script
- [ ] Handle environment isolation
- [ ] Test multi-SDK scenarios

### Phase 4: IDE Integration
- [ ] Create VSCode configuration helper
- [ ] Add IntelliSense setup
- [ ] Document debugging setup
- [ ] Test with real projects

### Phase 5: Polish & Documentation
- [ ] Comprehensive README
- [ ] Usage examples
- [ ] Troubleshooting guide
- [ ] CI/CD integration examples

---

## Benefits

### For Individual Developers
- ✅ Fast, consistent SDK setup across machines
- ✅ No manual SDK installation steps
- ✅ Automatic environment configuration
- ✅ Works in Codespaces, local containers, and CI

### For Teams
- ✅ Standardized development environment
- ✅ Easy onboarding for new developers
- ✅ Version-controlled SDK configuration
- ✅ Reduced "works on my machine" issues

### For Organizations
- ✅ Centralized SDK distribution
- ✅ Access control and audit trails
- ✅ Support for multiple products/architectures
- ✅ Easy SDK updates and rollbacks

---

## Example Use Cases

### Use Case 1: Single Product Development

\`\`\`json
{
  "name": "Embedded Product Development",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu-22.04",
  "features": {
    "ghcr.io/fabianschurig/devcontainer-features/yocto-esdk:1": {
      "repositoryUrl": "https://artifactory.company.com/yocto-sdk/product-a",
      "installerName": "poky-glibc-x86_64-product-a-armv8a-toolchain-ext-5.0.3.sh",
      "installPath": "/opt/product-a-sdk"
    }
  },
  "postCreateCommand": "cd /workspace && make"
}
\`\`\`

### Use Case 2: Multi-Architecture Development

\`\`\`json
{
  "name": "Multi-Architecture Development",
  "image": "mcr.microsoft.com/devcontainers/cpp:ubuntu-22.04",
  "features": {
    "ghcr.io/fabianschurig/devcontainer-features/yocto-esdk:1": {
      "sdks": [
        {
          "name": "rpi4-64bit",
          "repositoryUrl": "https://sdk.company.com/yocto",
          "installerName": "poky-glibc-x86_64-rpi-image-armv8a-toolchain-ext-5.0.3.sh",
          "installPath": "/opt/sdk/rpi4"
        },
        {
          "name": "imx8-industrial",
          "repositoryUrl": "https://sdk.company.com/yocto",
          "installerName": "poky-glibc-x86_64-imx-image-armv8a-toolchain-ext-5.0.3.sh",
          "installPath": "/opt/sdk/imx8"
        }
      ],
      "defaultSdk": "rpi4-64bit"
    }
  },
  "customizations": {
    "vscode": {
      "extensions": ["ms-vscode.cpptools", "ms-vscode.cmake-tools"]
    }
  }
}
\`\`\`

### Use Case 3: CI/CD Pipeline

\`\`\`yaml
# .github/workflows/build.yml
name: Build Embedded Application

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: mcr.microsoft.com/devcontainers/base:ubuntu-22.04
      
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Yocto SDK
        run: |
          # Use the same devcontainer feature approach
          curl -fsSL https://sdk.company.com/install.sh | bash
          
      - name: Build Application
        run: |
          source /opt/yocto-sdk/environment-setup-*
          make clean all
          
      - name: Run Tests
        run: |
          source /opt/yocto-sdk/environment-setup-*
          make test
\`\`\`

---

## References

### Yocto Project Documentation
- [Yocto eSDK Manual](https://docs.yoctoproject.org/sdk-manual/extensible.html)
- [Yocto SDK Manual](https://docs.yoctoproject.org/sdk-manual/index.html)
- [devtool Usage Guide](https://docs.yoctoproject.org/ref-manual/devtool-reference.html)

### Devcontainer Resources
- [Dev Container Features Spec](https://containers.dev/implementors/features/)
- [Feature Authoring Guide](https://containers.dev/guide/author-a-feature)
- [Feature Starter Template](https://github.com/devcontainers/feature-starter)
- [Feature Publishing Best Practices](https://containers.dev/guide/feature-authoring-best-practices)

### Community Examples
- [Good Penguin: Yocto SDK Guide](https://www.thegoodpenguin.co.uk/blog/everything-you-ought-to-know-and-more-about-yoctos-sdk-and-extensible-sdk-esdk/)
- [RocketBoards: eSDK Application Development](https://www.rocketboards.org/foswiki/Documentation/UsingYoctoExtendibleSdkForApplicationDevelopment)
- [GitHub: Yocto 101 eSDK Tutorial](https://github.com/VSChina/yocto-101/blob/master/app_development/yocto_esdk/build_app_with_yocto_esdk.md)

---

## Questions to Address

1. **License Compliance**: How to handle SDK license agreements during automated installation?
2. **Disk Space**: How much space to allocate? Should we support cleanup of old SDK versions?
3. **Update Strategy**: How to handle SDK updates without breaking existing containers?
4. **Offline Support**: Should we support pre-downloaded SDK installers for air-gapped environments?
5. **Windows Support**: Should we support Windows containers, or Linux-only?

---

## Success Criteria

The feature will be considered successful when:

1. ✅ Developers can add the feature to devcontainer.json with < 10 lines of config
2. ✅ SDK installation completes in < 5 minutes on average
3. ✅ No manual post-installation steps required
4. ✅ Works across different Yocto distributions (Poky, custom layers)
5. ✅ Supports at least 2 concurrent SDKs without conflicts
6. ✅ Clear error messages for common failure scenarios
7. ✅ Documentation is comprehensive and easy to follow

---

## Contact & Contribution

**Issue Creator**: FabianSchurig  
**Target Repository**: [FabianSchurig/devcontainer-features](https://github.com/FabianSchurig/devcontainer-features)  

**How to Contribute**:
1. Review this specification and provide feedback
2. Suggest additional use cases or requirements
3. Help with implementation and testing
4. Report issues and suggest improvements

---

*This specification is a living document and will be updated based on feedback and implementation learnings.*
