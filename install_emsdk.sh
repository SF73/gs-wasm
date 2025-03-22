#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Clone the EMSDK repository to your desired location (e.g., /opt/emsdk)
git clone https://github.com/emscripten-core/emsdk.git /opt/emsdk

# Navigate to the EMSDK directory
cd /opt/emsdk

# Check for the latest EMScripten version or set your desired version explicitly
LATEST_VERSION=latest
# Example: LATEST_VERSION=sdk-3.1.23
./emsdk install $LATEST_VERSION

# Activate the installed version
./emsdk activate $LATEST_VERSION

# Add EMSDK environment variables to the shell
source /opt/emsdk/emsdk_env.sh

# Verify the installation
emcc --version
