# Getting Started with Yocto devtool Multi-Repository POC

Quick start guide for the Yocto devtool multi-repository C++ workflow.

## What is This?

This POC demonstrates how to develop C++ applications that depend on libraries across multiple repositories using Yocto's `devtool` and `ide-sdk`, enabling fast iteration without full image rebuilds.

**Traditional Yocto**: 10-30 minute Edit-Compile-Debug cycles  
**This Workflow**: 10-60 second Edit-Compile-Debug cycles

## Prerequisites

✅ Docker installed  
✅ VSCode with Remote-Containers extension  
✅ Basic Yocto knowledge  
✅ ~20GB free disk space

## 5-Minute Setup

### 1. Clone the Repositories

The POC uses three components:

```bash
cd /home/runner/work/promptflow-starter-template

# These should already exist:
ls -la my-lib/    # C++ shared library (separate git repo)
ls -la my-app/    # C++ application (separate git repo)
ls -la promptflow-starter-template/yocto-devtool-poc/  # POC documentation
```

### 2. Clone Poky

```bash
git clone git://git.yoctoproject.org/poky $HOME/poky
cd $HOME/poky
git checkout kirkstone
```

### 3. Run the Setup Script

```bash
cd promptflow-starter-template/yocto-devtool-poc
./scripts/setup-workspace.sh
```

This automated script (takes 5-10 minutes):
- Initializes Yocto build environment
- Adds the recipes layer
- Runs `devtool modify` for both repos
- Builds my-lib
- Generates VSCode IDE configuration

### 4. Open and Build in VSCode

```bash
code /home/runner/work/promptflow-starter-template/my-app
```

1. Select CMake preset: `yocto-debug` (bottom toolbar)
2. Press `F7` to build
3. ✅ Done!

## What Just Happened?

1. **devtool modify**: Linked your local source code to Yocto recipes
2. **devtool build**: Compiled my-lib and populated its sysroot
3. **devtool ide-sdk**: Generated CMakeUserPresets.json with:
   - Cross-compilation toolchain
   - Recipe-specific sysroots
   - Proper include/library paths

4. **VSCode**: Now has full IntelliSense and can build using the generated CMake configuration

## Try It Out: Make a Change

Edit `my-lib/my-lib.cpp`:
```cpp
std::string getGreeting(const std::string& name) {
    return "Hello from MODIFIED library, " + name + "!";
}
```

Rebuild (takes seconds, not minutes):
```bash
devtool build my-lib  # ~15 seconds
devtool build my-app  # ~10 seconds
```

Run:
```bash
~/poky/build/workspace/sources/my-app/build/my-app
```

Output:
```
=== My Application ===
Hello from MODIFIED library, Developer!
5 + 7 = 12
```

**No image rebuild needed!** 🎉

## Repository Structure

```
/
├── my-lib/                           # Separate git repository
│   ├── .git/                         # Independent version control
│   ├── my-lib.h, my-lib.cpp          # Library source code
│   └── CMakeLists.txt                # CMake build config
│
├── my-app/                           # Separate git repository
│   ├── .git/                         # Independent version control
│   ├── main.cpp                      # Application source
│   └── CMakeLists.txt                # Links against my-lib
│
└── promptflow-starter-template/
    └── yocto-devtool-poc/            # POC documentation & recipes
        ├── recipes-example/          # Yocto layer
        │   ├── my-lib/my-lib_1.0.bb  # Library recipe
        │   └── my-app/my-app_1.0.bb  # App recipe (DEPENDS = "my-lib")
        ├── .devcontainer/            # VSCode container config
        ├── scripts/                  # Automation scripts
        └── docs/                     # Documentation
```

## Key Concepts

### 1. External Source (EXTERNALSRC)

devtool creates `.bbappend` files that point to your local repos:
```python
EXTERNALSRC = "/path/to/my-lib"
```

This means changes in your repo are immediately visible to Yocto.

### 2. Recipe-Specific Sysroots

Each recipe gets its own sysroot with dependencies:
```
workspace/recipes/my-app/recipe-sysroot/
└── usr/
    ├── include/         # Headers from dependencies (my-lib)
    └── lib/             # Libraries from dependencies (libMyLib.so)
```

### 3. CMake Integration

`devtool ide-sdk` generates presets that tell CMake where to find everything:
```json
{
  "CMAKE_PREFIX_PATH": "/path/to/my-lib/sysroot/usr",
  "CMAKE_TOOLCHAIN_FILE": "/path/to/cross-toolchain.cmake"
}
```

## Common Commands

```bash
# Check workspace status
devtool status

# Build a component
devtool build my-lib

# Clean and rebuild
devtool build -c clean my-lib
devtool build my-lib

# Deploy to target device
devtool deploy-target my-app root@192.168.1.100

# Remove from workspace (keep sources)
devtool reset my-lib
```

## Next Steps

- 📖 Read [README.md](README.md) for complete documentation
- 📋 Read [docs/WORKFLOW.md](docs/WORKFLOW.md) for detailed workflow guide
- 🐛 See [docs/WORKFLOW.md#troubleshooting](docs/WORKFLOW.md#troubleshooting) if you encounter issues
- 🚀 Explore remote debugging with `devtool ide-sdk --gdb`

## Troubleshooting

### "CMake can't find MyLib"
```bash
devtool build my-lib  # Populate sysroot
devtool ide-sdk my-lib my-app core-image-minimal  # Regenerate presets
```

### "Changes not reflected"
```bash
devtool build -c clean my-lib
devtool build my-lib
```

### "DevContainer won't start"
```bash
docker volume create yocto-sstate-cache
docker volume create yocto-downloads
```

## Success Criteria

You've successfully completed the POC setup when:

✅ `devtool status` shows both my-lib and my-app  
✅ VSCode can build my-app using CMake presets  
✅ `find_package(MyLib)` succeeds in my-app  
✅ You can modify my-lib and rebuild in under 1 minute  
✅ Changes are reflected without image rebuild

## Support

- **Documentation**: See README.md and docs/ directory
- **Issues**: Check docs/WORKFLOW.md#troubleshooting
- **Examples**: CMake presets in docs/CMakeUserPresets.json.example

---

**Ready to start?** Run `./scripts/setup-workspace.sh` and follow along! 🚀
