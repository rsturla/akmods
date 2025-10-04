#!/bin/sh

set -ouex pipefail

# Check if a build context was provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <build-context-path>"
    exit 1
fi

BUILD_CONTEXT="$1"

# Load Nvidia variables
source "${BUILD_CONTEXT}"/info/nvidia-vars

ARCH=$(uname -m)

# Install Nvidia addons from the build context
dnf install -y "${BUILD_CONTEXT}"/rpms/nvidia-addons-*.rpm

# Enable Nvidia-related repositories
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/nvidia-container-toolkit.repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/negativo17-fedora-nvidia.repo

# Base packages to install
COMMON_PKGS=(
    libnvidia-fbc
    libva-nvidia-driver
    nvidia-driver
    nvidia-modprobe
    nvidia-persistenced
    nvidia-driver-cuda
    nvidia-settings
    nvidia-container-toolkit
    "${BUILD_CONTEXT}"/rpms/kmod-nvidia-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm
)

# Declare an array for architecture-specific packages
ARCH_PKGS=()

# Add architecture-specific packages based on detected architecture
if [ "$ARCH" = "x86_64" ]; then
    ARCH_PKGS=(
        libnvidia-ml.i686
        mesa-vulkan-drivers.i686
        nvidia-driver-cuda-libs.i686
        nvidia-driver-libs.i686
        egl-wayland2.x86_64
        egl-wayland2.i686
    )
elif [ "$ARCH" = "aarch64" ]; then
    # No additional packages for aarch64
    ARCH_PKGS=()
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Install all packages
dnf install -y "${COMMON_PKGS[@]}" "${ARCH_PKGS[@]}"

# Ensure the version of the Nvidia module matches the driver
KMOD_VERSION="$(rpm -q --queryformat '%{VERSION}' kmod-nvidia)"
DRIVER_VERSION="$(rpm -q --queryformat '%{VERSION}' nvidia-driver)"
if [ "$KMOD_VERSION" != "$DRIVER_VERSION" ]; then
    echo "Error: kmod-nvidia version ($KMOD_VERSION) does not match nvidia-driver version ($DRIVER_VERSION)"
    exit 1
fi

# Copy and update modprobe configuration for Nvidia
cp /etc/modprobe.d/nvidia-modeset.conf /usr/lib/modprobe.d/nvidia-modeset.conf
sed -i 's@omit_drivers@force_drivers@g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf

# Copy akmods certs
cp "${BUILD_CONTEXT}"/certs/* /etc/pki/akmods/certs/
