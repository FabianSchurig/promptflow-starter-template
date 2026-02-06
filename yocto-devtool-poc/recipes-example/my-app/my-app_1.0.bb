SUMMARY = "My C++ application"
DESCRIPTION = "A sample C++ application that uses my-lib for demonstrating Yocto devtool workflow"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# Update this to point to your actual repository
SRC_URI = "git://github.com/example/my-app.git;protocol=https;branch=main"
SRCREV = "${AUTOREV}"

# For local development, you can also use:
# SRC_URI = "file:///path/to/my-app"
# Or devtool will handle this automatically with: devtool modify my-app /path/to/my-app

S = "${WORKDIR}/git"

# Declare dependency on my-lib
# This ensures my-lib is built and available before my-app
DEPENDS = "my-lib"

inherit cmake

# Enable parallel build
PARALLEL_MAKE = "-j ${@oe.utils.cpu_count()}"

# Runtime dependencies
RDEPENDS:${PN} = "my-lib"

FILES:${PN} = "${bindir}/my-app"
