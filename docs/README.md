# Yocto eSDK Devcontainer Feature Documentation

This directory contains comprehensive documentation for creating a Yocto eSDK devcontainer feature.

## Files in This Directory

### 1. yocto-esdk-devcontainer-feature-spec.md
**Complete Technical Specification**

This is the comprehensive specification document that contains:
- Detailed background on Yocto eSDK architecture
- Complete feature requirements and design approach
- Implementation details and code examples
- Testing strategy and success criteria
- Repository distribution best practices
- Security considerations
- Multiple use case examples
- Complete reference links

**Use this document for**: Implementation reference, technical discussions, and detailed planning

### 2. GITHUB_ISSUE_TEMPLATE.md
**GitHub Issue Template**

This is a concise template formatted for creating a GitHub issue. It contains:
- Problem statement and proposed solution
- Must-have, should-have, and nice-to-have requirements
- Example configurations
- Implementation phases
- Success criteria
- Questions for discussion

**Use this document for**: Copy-paste into GitHub issue creation in the FabianSchurig/devcontainer-features repository

## How to Create the GitHub Issue

Since GitHub issue creation cannot be automated from this environment, follow these steps:

1. Navigate to: https://github.com/FabianSchurig/devcontainer-features/issues/new

2. Copy the contents of `GITHUB_ISSUE_TEMPLATE.md` and paste into the issue description

3. Use this title:
   ```
   Create minimal devcontainer feature for Yocto eSDK setup with multi-SDK support
   ```

4. Add these labels:
   - enhancement
   - devcontainer
   - yocto
   - feature-request

5. Reference the full specification by linking to this repository or attaching the `yocto-esdk-devcontainer-feature-spec.md` file

## Quick Summary

**Goal**: Create a minimal, maintainable devcontainer feature for Yocto eSDK installation

**Key Features**:
- Download SDK from configurable repositories (Artifactory, Nexus, etc.)
- Support multiple SDKs for different architectures
- Automatic environment configuration
- Authentication for private repositories
- Checksum verification for security

**Benefits**:
- Fast, consistent SDK setup
- Works in Codespaces, local containers, and CI
- Reduces onboarding time
- Standardized development environment
- Support for multiple Yocto distributions

## Research Summary

### Yocto eSDK (Extensible SDK)
- Advanced development kit for embedded Linux development
- Unlike standard SDK, it's updateable and extensible
- Includes devtool for managing recipes and applications
- Contains complete sysroot matched to target image
- Typical installer: `poky-glibc-x86_64-<image>-<arch>-toolchain-ext-<version>.sh`

### Devcontainer Features
- Standardized way to add tools to dev containers
- Configuration via JSON with options
- Install script receives options as environment variables
- Can be published to GitHub Container Registry (GHCR)
- Example: `ghcr.io/owner/repo/feature-name:version`

### Best Practices for SDK Distribution
- Store SDK installers in Artifactory/Nexus
- Use clear naming conventions with version, architecture
- Provide SHA256 checksums for integrity verification
- Implement access control for private SDKs
- Support HTTPS-only downloads

## Next Steps

1. **Create GitHub Issue**: Use the template provided
2. **Set up Repository**: Fork or create devcontainer-features repository
3. **Implement MVP**: Start with Phase 1 (basic single SDK installation)
4. **Test**: Validate with real Yocto SDKs
5. **Iterate**: Add multi-SDK support and advanced features
6. **Document**: Create comprehensive README and usage examples
7. **Publish**: Push to GHCR for community use

## Contact

For questions or contributions:
- Repository Owner: FabianSchurig
- Target Repository: https://github.com/FabianSchurig/devcontainer-features

---

*Last Updated: February 6, 2026*
