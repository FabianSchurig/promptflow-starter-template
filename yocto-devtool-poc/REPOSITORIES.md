# Repository Structure

This POC consists of **three separate components** demonstrating a true multi-repository workflow.

## Component Locations

### 1. my-lib Repository
**Location**: `/home/runner/work/promptflow-starter-template/my-lib/`
**Type**: Separate Git repository
**Purpose**: C++ shared library

```bash
cd /home/runner/work/promptflow-starter-template/my-lib
git log --oneline
```

**Contents**:
- `my-lib.h`: Library header with API declarations
- `my-lib.cpp`: Library implementation
- `CMakeLists.txt`: CMake build configuration
- `MyLibConfig.cmake.in`: CMake package config template
- `README.md`: Library-specific documentation

**Git Status**: ✅ Initialized with initial commit

### 2. my-app Repository
**Location**: `/home/runner/work/promptflow-starter-template/my-app/`
**Type**: Separate Git repository
**Purpose**: C++ application that depends on my-lib

```bash
cd /home/runner/work/promptflow-starter-template/my-app
git log --oneline
```

**Contents**:
- `main.cpp`: Application entry point
- `CMakeLists.txt`: CMake build with `find_package(MyLib REQUIRED)`
- `README.md`: Application-specific documentation

**Git Status**: ✅ Initialized with initial commit

### 3. yocto-devtool-poc (This Directory)
**Location**: `/home/runner/work/promptflow-starter-template/promptflow-starter-template/yocto-devtool-poc/`
**Type**: Part of promptflow-starter-template repository
**Purpose**: POC documentation, Yocto recipes, automation scripts

```bash
cd /home/runner/work/promptflow-starter-template/promptflow-starter-template
git log --oneline yocto-devtool-poc/
```

**Contents**:
- `recipes-example/`: Yocto layer with recipes for both my-lib and my-app
- `.devcontainer/`: VSCode DevContainer configuration
- `scripts/`: Automation scripts (setup, build)
- `docs/`: Documentation (workflow guide, examples)
- `README.md`, `GETTING_STARTED.md`: Documentation

## Why Separate Repositories?

This structure demonstrates a **real-world multi-repository workflow**:

1. **Independent Versioning**
   - my-lib can be versioned independently (v1.0, v1.1, v2.0)
   - my-app can pin to specific my-lib versions

2. **Team Collaboration**
   - Library team works in my-lib repo
   - Application team works in my-app repo
   - Both teams can iterate independently

3. **Reusability**
   - my-lib can be used by multiple applications
   - Each application maintains its own repository

4. **Realistic Scenario**
   - Mirrors enterprise development patterns
   - Demonstrates devtool's capability with external sources

## Yocto Integration

The Yocto recipes in `recipes-example/` reference these repositories:

### my-lib_1.0.bb
```python
SRC_URI = "git://github.com/example/my-lib.git;protocol=https;branch=main"
# Or when using devtool:
# EXTERNALSRC = "/path/to/my-lib"
```

### my-app_1.0.bb
```python
SRC_URI = "git://github.com/example/my-app.git;protocol=https;branch=main"
DEPENDS = "my-lib"  # Declares dependency
# Or when using devtool:
# EXTERNALSRC = "/path/to/my-app"
```

## devtool Workflow

The `devtool modify` command links these repositories to Yocto:

```bash
# Link my-lib repo to Yocto workspace
devtool modify my-lib /home/runner/work/promptflow-starter-template/my-lib

# Link my-app repo to Yocto workspace
devtool modify my-app /home/runner/work/promptflow-starter-template/my-app
```

This creates `.bbappend` files that set `EXTERNALSRC` to point to your local repositories.

## Verification

### Check Repository Structure

```bash
# my-lib repository
cd /home/runner/work/promptflow-starter-template/my-lib
git status
git log --oneline

# my-app repository
cd /home/runner/work/promptflow-starter-template/my-app
git status
git log --oneline

# POC in main repository
cd /home/runner/work/promptflow-starter-template/promptflow-starter-template
git log --oneline yocto-devtool-poc/
```

### Check Files

```bash
# Library files
ls -la /home/runner/work/promptflow-starter-template/my-lib/

# Application files
ls -la /home/runner/work/promptflow-starter-template/my-app/

# POC files
ls -la /home/runner/work/promptflow-starter-template/promptflow-starter-template/yocto-devtool-poc/
```

## For Production Use

To use this POC in a real project:

1. **Push repositories to GitHub/GitLab**:
   ```bash
   cd /home/runner/work/promptflow-starter-template/my-lib
   git remote add origin https://github.com/yourorg/my-lib.git
   git push -u origin main
   
   cd /home/runner/work/promptflow-starter-template/my-app
   git remote add origin https://github.com/yourorg/my-app.git
   git push -u origin main
   ```

2. **Update recipes** with actual repository URLs:
   ```python
   SRC_URI = "git://github.com/yourorg/my-lib.git;protocol=https;branch=main"
   SRCREV = "${AUTOREV}"  # Or pin to specific commit
   ```

3. **Clone for development**:
   ```bash
   git clone https://github.com/yourorg/my-lib.git
   git clone https://github.com/yourorg/my-app.git
   ```

## Summary

✅ **my-lib**: `/home/runner/work/promptflow-starter-template/my-lib/` (separate git repo)  
✅ **my-app**: `/home/runner/work/promptflow-starter-template/my-app/` (separate git repo)  
✅ **yocto-devtool-poc**: `promptflow-starter-template/yocto-devtool-poc/` (POC & recipes)

This structure demonstrates a true multi-repository workflow as specified in the acceptance criteria.
