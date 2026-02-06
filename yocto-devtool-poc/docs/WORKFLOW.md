# Multi-Repository C++ Workflow Guide

Complete guide for the Yocto devtool multi-repository C++ development workflow.

## Table of Contents

1. [Initial Setup](#initial-setup)
2. [Workspace Initialization](#workspace-initialization)
3. [IDE Configuration](#ide-configuration)
4. [Development Workflow](#development-workflow)
5. [Debugging](#debugging)
6. [Troubleshooting](#troubleshooting)

## Initial Setup

### 1.1 Clone Poky

```bash
git clone git://git.yoctoproject.org/poky $HOME/poky
cd $HOME/poky
git checkout kirkstone  # Or scarthgap for newer version
```

### 1.2 Initialize Build Environment

```bash
source oe-init-build-env build
```

### 1.3 Add Recipe Layer

```bash
bitbake-layers add-layer /path/to/yocto-devtool-poc/recipes-example
```

Verify:
```bash
bitbake-layers show-layers | grep yocto-devtool-poc
```

## Workspace Initialization

### 2.1 Initialize devtool for my-lib

```bash
devtool modify my-lib /path/to/my-lib
```

This creates:
- `workspace/appends/my-lib_1.0.bbappend`
- Sets `EXTERNALSRC = "/path/to/my-lib"`

### 2.2 Initialize devtool for my-app

```bash
devtool modify my-app /path/to/my-app
```

### 2.3 Verify Workspace

```bash
devtool status
```

Expected output:
```
my-lib: /path/to/my-lib
my-app: /path/to/my-app
```

## IDE Configuration

### 3.1 Build my-lib First

**Critical**: Build my-lib to populate its sysroot before generating IDE config.

```bash
devtool build my-lib
```

This executes:
- `do_configure`: Run CMake
- `do_compile`: Build sources
- `do_install`: Install to temp
- `do_populate_sysroot`: **Create sysroot with MyLibConfig.cmake**

### 3.2 Generate IDE SDK

```bash
devtool ide-sdk my-lib my-app core-image-minimal
```

Generates:
- `my-lib/CMakeUserPresets.json`
- `my-app/CMakeUserPresets.json`
- Optional: `.vscode/launch.json` for debugging

### 3.3 Inspect Generated Configuration

```bash
cat my-app/CMakeUserPresets.json
```

Key variables:
- `CMAKE_TOOLCHAIN_FILE`: Cross-compilation toolchain
- `CMAKE_PREFIX_PATH`: Includes my-lib sysroot
- `CMAKE_SYSROOT`: Target system root

## Development Workflow

### 4.1 Open Project in VSCode

```bash
code /path/to/my-app
```

### 4.2 Select CMake Preset

1. Open Command Palette: `Ctrl+Shift+P`
2. Run: `CMake: Select Configure Preset`
3. Choose: `yocto-debug` or `yocto-release`

### 4.3 Build Project

- **Option 1**: Click "Build" in CMake Tools sidebar
- **Option 2**: Press `F7`
- **Option 3**: Command Palette → `CMake: Build`

### 4.4 Iteration Cycle

#### Modify Library

Edit `my-lib/my-lib.cpp`:
```cpp
std::string getGreeting(const std::string& name) {
    return "Greetings, " + name + "! [Version 2.0]";
}
```

#### Rebuild Library

```bash
devtool build my-lib  # 10-30 seconds
```

#### Rebuild Application

```bash
devtool build my-app  # 5-15 seconds
```

#### Test Changes

```bash
# Deploy to target
devtool deploy-target my-app root@192.168.1.100

# Or test locally (if same architecture)
./my-app/build/my-app
```

**Result**: Changes reflected without 10-30 minute image rebuild!

## Debugging

### 5.1 Local Debugging (Same Architecture)

If developing x86_64 for x86_64:

```bash
# Build with debug symbols
devtool ide-sdk --build-type Debug my-lib my-app core-image-minimal
devtool build my-lib
devtool build my-app

# Debug in VSCode: F5
```

### 5.2 Remote Debugging (Cross-Architecture)

For ARM target on x86_64 host:

#### Generate Debug Configuration

```bash
devtool ide-sdk --gdb my-lib my-app core-image-minimal
```

#### Deploy to Target

```bash
devtool deploy-target my-app root@target-ip
```

#### Start gdbserver on Target

```bash
ssh root@target-ip
gdbserver :2345 /usr/bin/my-app
```

#### Debug in VSCode

1. Select "Debug my-app (Remote)" configuration
2. Press `F5`
3. Set breakpoints and step through code

## Troubleshooting

### Problem: CMake can't find MyLib

**Symptoms**:
```
CMake Error: Could not find a package configuration file provided by "MyLib"
```

**Solution**:
```bash
# Ensure sysroot is populated
devtool build my-lib

# Verify MyLibConfig.cmake exists
ls ~/poky/build/workspace/recipes/my-lib/recipe-sysroot/usr/lib/cmake/MyLib/

# Regenerate IDE config
devtool ide-sdk my-lib my-app core-image-minimal
```

### Problem: Changes not reflected after rebuild

**Symptoms**: Modified code doesn't change behavior

**Solution**:
```bash
# Clean build
devtool build -c clean my-lib
devtool build my-lib

# If still not working, clean shared state
devtool build -c cleansstate my-lib
devtool build my-lib
```

### Problem: DevContainer won't start

**Symptoms**: Docker volume errors

**Solution**:
```bash
# Create volumes manually
docker volume create yocto-sstate-cache
docker volume create yocto-downloads

# Rebuild container in VSCode
```

### Problem: Cross-compiled binary won't run

**Symptoms**: "cannot execute binary file: Exec format error"

**Solution**:  
This is expected for cross-compilation. Use:
- QEMU: `runqemu qemux86-64`
- Real hardware: `devtool deploy-target`
- Remote debugging: See section 5.2

## Command Reference

### Workspace Management

```bash
devtool modify <recipe> <srctree>    # Add to workspace
devtool status                        # Show workspace status
devtool reset <recipe>                # Remove from workspace
devtool finish <recipe> <layer>       # Integrate to layer
```

### Building

```bash
devtool build <recipe>                # Build recipe
devtool build -c clean <recipe>       # Clean build
devtool build -c cleansstate <recipe> # Clean shared state
```

### Deployment

```bash
devtool deploy-target <recipe> <target>  # Deploy to target
devtool undeploy-target <recipe> <tgt>   # Remove from target
```

### IDE Integration

```bash
devtool ide-sdk <recipes> <image>        # Generate IDE config
devtool ide-sdk --gdb <recipes> <img>    # With debug config
devtool ide-sdk --build-type Debug ...   # Debug build type
```

## Performance Comparison

| Workflow | Iteration Time | Notes |
|----------|----------------|-------|
| Traditional BitBake | 10-30 minutes | Full image rebuild |
| **devtool** | **10-60 seconds** | Incremental, no image rebuild |

**Speedup**: 20-30x faster

## Best Practices

1. **Build Library First**: Always `devtool build my-lib` before my-app
2. **Regenerate Presets**: After recipe changes, run `ide-sdk` again
3. **Clean When Stuck**: Use `-c clean` or `-c cleansstate`
4. **Version Control**: Keep my-lib and my-app as separate repos
5. **Use Workspace Status**: Check `devtool status` regularly

## Summary

The devtool + ide-sdk workflow enables:
- ✅ Fast iteration (seconds vs minutes)
- ✅ IDE integration (IntelliSense, debugging)
- ✅ Multi-repository development
- ✅ No image rebuilds required
- ✅ Proper dependency management

This bridges Yocto's reproducibility with modern development practices.
