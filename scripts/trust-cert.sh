#!/bin/bash

# Define the container name and certificate path inside the container
CONTAINER_NAME=$(docker ps --filter "name=caddy" --format "{{.Names}}" | head -n 1)
CERT_PATH_IN_CONTAINER="/data/caddy/pki/authorities/local/root.crt"

# Function to install certificate on Linux
install_cert_linux() {
    # Define the destination path on the host
    DEST_PATH="/usr/local/share/ca-certificates/caddy-root.crt"

    # Extract the certificate from the container
    docker cp "$CONTAINER_NAME:$CERT_PATH_IN_CONTAINER" "$DEST_PATH"

    # Update CA certificates to trust the extracted certificate
    sudo update-ca-certificates

    # Restarting the browser may be necessary, which can't be scripted
    echo "Certificate installed on Linux. Please restart your browser."
}

# Function to install certificate on macOS
install_cert_macos() {
    # Define a temporary path on the host
    TEMP_CERT_PATH="/tmp/caddy-root.crt"

    # Extract the certificate from the container
    docker cp "$CONTAINER_NAME:$CERT_PATH_IN_CONTAINER" "$TEMP_CERT_PATH"

    # Import and trust the certificate in the system keychain
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$TEMP_CERT_PATH"

    # Clean up the temp certificate file
    rm "$TEMP_CERT_PATH"

    # Inform user of completion
    echo "Certificate installed and trusted on macOS. You may need to restart your browser."
}

# Detect the operating system
OS=$(uname -s)

case "$OS" in
    Linux*)     install_cert_linux;;
    Darwin*)    install_cert_macos;;
    *)          echo "Unsupported operating system: $OS"; exit 1;;
esac
