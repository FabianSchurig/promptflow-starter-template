# GitHub Issue: Yocto eSDK Devcontainer Feature

**Title**: Create minimal devcontainer feature for Yocto eSDK setup with multi-SDK support

---

## Summary

Create a reusable, minimal devcontainer feature for setting up Yocto Extensible SDK (eSDK) and IDE-SDK in development containers. The feature should support downloading SDKs from configurable repositories (Artifactory, Nexus, HTTP servers) and enable multi-SDK setups for different target architectures.

## Problem Statement

Currently, setting up Yocto eSDK environments requires:
- Manual SDK installation and environment configuration
- Repetitive setup across different machines/containers
- Custom scripts for team collaboration
- Complex handling of multiple SDK versions/architectures

This leads to inconsistent development environments, difficult onboarding, and "works on my machine" problems.

## Proposed Solution

A devcontainer feature that:
1. Downloads eSDK installer from configurable repository URL
2. Installs SDK with minimal configuration
3. Automatically configures the development environment
4. Supports multiple SDKs for different architectures/distributions
5. Provides authentication for private repositories
6. Verifies integrity via checksums

## Requirements

### Must Have (MVP)
- [ ] Download and install single eSDK from repository URL
- [ ] Support basic HTTP authentication (username/password)
- [ ] Automatic environment sourcing in shell sessions
- [ ] Configurable installation paths
- [ ] Checksum verification support

### Should Have
- [ ] Multi-SDK support with SDK selector utility
- [ ] Token-based authentication
- [ ] VSCode IntelliSense integration
- [ ] Clear error messages and troubleshooting

### Nice to Have
- [ ] Offline/air-gapped installation support
- [ ] SDK update/rollback mechanisms
- [ ] CI/CD integration examples
- [ ] GPG signature verification

## Example Configuration

### Basic Single SDK Setup
\`\`\`json
{
  "features": {
    "ghcr.io/fabianschurig/devcontainer-features/yocto-esdk:1": {
      "repositoryUrl": "https://artifactory.company.com/yocto-sdk",
      "installerName": "poky-glibc-x86_64-core-image-minimal-armv8a-toolchain-ext-5.0.3.sh",
      "installPath": "/opt/yocto-sdk",
      "autoSource": true
    }
  }
}
\`\`\`

### Multi-SDK Setup
\`\`\`json
{
  "features": {
    "ghcr.io/fabianschurig/devcontainer-features/yocto-esdk:1": {
      "sdks": [
        {
          "name": "armv8a",
          "repositoryUrl": "https://artifactory.company.com/yocto-sdk",
          "installerName": "poky-...-armv8a-toolchain-ext-5.0.3.sh",
          "installPath": "/opt/yocto-sdk/armv8a"
        },
        {
          "name": "cortexa7",
          "repositoryUrl": "https://artifactory.company.com/yocto-sdk",
          "installerName": "poky-...-cortexa7t2hf-toolchain-ext-5.0.3.sh",
          "installPath": "/opt/yocto-sdk/cortexa7"
        }
      ],
      "defaultSdk": "armv8a"
    }
  }
}
\`\`\`

## Technical Approach

### Architecture
- Single-purpose feature focusing on SDK installation/setup only
- Leverage existing eSDK installation mechanisms (no reimplementation)
- Configuration-driven design with minimal scripting
- Environment variable-based option passing

### Key Components
1. **install.sh**: Main installation script
   - Downloads SDK installer from repository
   - Verifies checksums
   - Executes installer with proper flags
   - Configures shell environment

2. **devcontainer-feature.json**: Feature metadata
   - Defines configurable options
   - Specifies version and dependencies
   - Documents usage

3. **yocto-sdk-select**: SDK selector utility (for multi-SDK)
   - Lists available installed SDKs
   - Activates selected SDK environment
   - Prevents environment conflicts

### Security Considerations
- HTTPS-only downloads
- Checksum verification before installation
- Support for authenticated repositories
- Never hardcode credentials (use secrets/env vars)
- SSL certificate validation

## Benefits

### For Developers
✅ Zero-config SDK setup in containers  
✅ Consistent environment across machines  
✅ Works in Codespaces, local dev containers, and CI  
✅ Fast onboarding for new team members  

### For Teams
✅ Standardized development environment  
✅ Version-controlled SDK configuration  
✅ Easy SDK version updates  
✅ Support multiple products/architectures  

### For Organizations
✅ Centralized SDK distribution  
✅ Access control and audit trails  
✅ Reduced support overhead  
✅ Better security posture  

## Implementation Phases

### Phase 1: MVP (Week 1-2)
- Basic feature structure
- Single SDK installation
- HTTP download with auth
- Checksum verification
- Basic documentation

### Phase 2: Multi-SDK (Week 3)
- Multiple SDK support
- SDK selector script
- Environment isolation
- Advanced configuration

### Phase 3: Polish (Week 4)
- IDE integration
- Comprehensive docs
- Testing across distributions
- CI/CD examples

## Success Criteria

1. ✅ < 10 lines of config to add feature
2. ✅ < 5 minutes SDK installation time
3. ✅ No manual post-installation steps
4. ✅ Works with Poky and custom Yocto layers
5. ✅ Supports 2+ concurrent SDKs
6. ✅ Clear error messages
7. ✅ Comprehensive documentation

## References

- **Full Specification**: See [yocto-esdk-devcontainer-feature-spec.md](./docs/yocto-esdk-devcontainer-feature-spec.md) for detailed design
- **Yocto Documentation**: https://docs.yoctoproject.org/sdk-manual/extensible.html
- **Devcontainer Features**: https://containers.dev/guide/author-a-feature
- **Feature Starter**: https://github.com/devcontainers/feature-starter

## Questions for Discussion

1. Should we support Windows containers or focus on Linux-only?
2. How to handle SDK license agreements in automated installations?
3. What's the preferred approach for SDK version updates?
4. Should we support offline/air-gapped scenarios initially?
5. What level of IDE integration is expected (VSCode, others)?

---

**Labels**: enhancement, devcontainer, yocto, feature-request  
**Assignees**: @FabianSchurig  
**Repository**: FabianSchurig/devcontainer-features
