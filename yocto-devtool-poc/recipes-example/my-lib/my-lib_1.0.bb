SUMMARY = "My C++ shared library"
DESCRIPTION = "A sample C++ shared library for demonstrating Yocto devtool workflow"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# Update this to point to your actual repository
SRC_URI = "git://github.com/example/my-lib.git;protocol=https;branch=main"
SRCREV = "${AUTOREV}"

# For local development, you can also use:
# SRC_URI = "file:///path/to/my-lib"
# Or devtool will handle this automatically with: devtool modify my-lib /path/to/my-lib

S = "${WORKDIR}/git"

inherit cmake

# Enable parallel build
PARALLEL_MAKE = "-j ${@oe.utils.cpu_count()}"

# Install the library
do_install:append() {
    # Create directories if they don't exist
    install -d ${D}${libdir}
    install -d ${D}${includedir}
}

FILES:${PN} = "${libdir}/libMyLib.so.*"
FILES:${PN}-dev = "${includedir} ${libdir}/libMyLib.so ${libdir}/cmake"

BBCLASSEXTEND = "native nativesdk"
