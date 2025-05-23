#!/bin/bash
# script to automate an RKE2 upgrade in an air-gapped environment

VERSION_DIR="$1"                     
ETCD_BACKUP_DIR="${VERSION_DIR}/etcd"             
OLD_IMAGES_DIR="${VERSION_DIR}/old_images"
RKE2_IMAGES_DIR="/var/lib/rancher/rke2/agent/images" 
BIN_DIR="/usr/local/bin"                             
BACKUP_BIN_DIR="${VERSION_DIR}/old_bin" 

IMAGES_TAR="rke2-images.linux-amd64.tar.zst" 
CNI_TAR="rke2-images-canal.linux-amd64.tar.zst"
BINARY_TAR="rke2.linux-amd64.tar.gz"                 
CHECKSUM_FILE="sha256sum-amd64.txt"                       

# Source directory for new artifacts
SOURCE_DIR="${VERSION_DIR}"
TMP_DIR="/tmp/rke2"
# Global variables for rollback
SERVICE_NAME="$2"
ROLLBACK_NEEDED=false

verify_checksums() {
    echo "Verifying checksums of artifacts..."
    cd "$VERSION_DIR" || exit 1
    
    if [ ! -f "$CHECKSUM_FILE" ]; then
        echo "ERROR: Checksum file $CHECKSUM_FILE not found in $VERSION_DIR"
        exit 1
    fi
    
    # Verify checksums
    if ! sha256sum -c $VERSION_DIR/"$CHECKSUM_FILE" --ignore-missing; then
        echo "ERROR: Checksum verification failed for one or more files"
        exit 1
    fi
    
    echo "All checksums verified successfully"
}

backup_etcd() {
    if systemctl is-active --quiet rke2-server; then
        SERVICE_NAME="rke2-server"
        echo "Detected RKE2 server node, performing etcd backup..."

        mkdir -p "$ETCD_BACKUP_DIR"

       
        SNAPSHOT_NAME="etcd-snapshot"

        echo "Creating etcd snapshot: ${SNAPSHOT_NAME} in ${ETCD_BACKUP_DIR}"

        # Run etcd snapshot command with compression
        if ! rke2 etcd-snapshot save \
            --snapshot-compress \
            --name "$SNAPSHOT_NAME" \
            --dir "$ETCD_BACKUP_DIR"; then
            echo "WARNING: etcd backup failed, proceeding anyway"
        else
            echo "etcd backup completed successfully at ${ETCD_BACKUP_DIR}"
        fi
    else
        echo "Not a server node, skipping etcd backup"
    fi
}



# Function to backup old binary
backup_old_binary() {
    echo "Backing up current RKE2 binary..."
    
    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_BIN_DIR"
    
    # Backup the binary
    if [ -f "${BIN_DIR}/rke2" ]; then
        echo "Backing up current rke2 binary"
        cp "${BIN_DIR}/rke2" "${BACKUP_BIN_DIR}/rke2.bak"
    else
        echo "WARNING: Current rke2 binary not found in ${BIN_DIR}"
    fi
}

# Function to backup old images
backup_old_images() {
    echo "Backing up old RKE2 images..."
    
    # Create old images directory if it doesn't exist
    mkdir -p "$OLD_IMAGES_DIR"
    
    # Backup each existing image file
    for img_file in "${RKE2_IMAGES_DIR}"/*; do
        if [ -f "$img_file" ]; then
            filename=$(basename "$img_file")
            echo "Backing up $filename"
            mv "$img_file" "${OLD_IMAGES_DIR}/${filename}.bak"
        fi
    done
    
    echo "Old images backed up to $OLD_IMAGES_DIR"
}



# Function to deploy new images
deploy_new_images() {
    echo "Deploying new RKE2 images and CNI plugins..."

    # Verify images tarballs exist
    if [ ! -f "${VERSION_DIR}/${IMAGES_TAR}" ]; then
        echo "ERROR: Images tarball ${IMAGES_TAR} not found in ${VERSION_DIR}"
        exit 1
    fi
    
    if [ ! -f "${VERSION_DIR}/${CNI_TAR}" ]; then
        echo "ERROR: CNI tarball ${CNI_TAR} not found in ${VERSION_DIR}"
        exit 1
    fi

    # Copy new images with verification
    echo "Copying ${IMAGES_TAR} to ${RKE2_IMAGES_DIR}/"
    if ! cp "${VERSION_DIR}/${IMAGES_TAR}" "${RKE2_IMAGES_DIR}/"; then
        echo "ERROR: Failed to copy ${IMAGES_TAR}"
        exit 1
    fi
    
    echo "Copying ${CNI_TAR} to ${RKE2_IMAGES_DIR}/"
    if ! cp "${VERSION_DIR}/${CNI_TAR}" "${RKE2_IMAGES_DIR}/"; then
        echo "ERROR: Failed to copy ${CNI_TAR}"
        # Attempt to clean up partially copied files
        rm -f "${RKE2_IMAGES_DIR}/${IMAGES_TAR}"
        exit 1
    fi
    
    echo "New images and CNI plugins deployed successfully to ${RKE2_IMAGES_DIR}/"
}



# Function to deploy new binary
deploy_new_binary() {
    echo "Deploying new RKE2 binary..."

    if systemctl is-active --quiet rke2-server; then
        SERVICE_NAME="rke2-server"
    fi

    if [ ! -f "${VERSION_DIR}/${BINARY_TAR}" ]; then
        echo "ERROR: Binary tarball ${BINARY_TAR} not found in ${VERSION_DIR}"
        exit 1
    fi

    echo "Stopping $SERVICE_NAME service..."
    systemctl stop "$SERVICE_NAME"

    rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"

    echo "Extracting ${BINARY_TAR} to ${TMP_DIR}/"
    if ! tar xzf "${VERSION_DIR}/${BINARY_TAR}" -C "$TMP_DIR"; then
        echo "ERROR: Failed to extract binary tarball"
        exit 1
    fi

    if ! cp "$TMP_DIR/bin/rke2" "${BIN_DIR}/"; then
        echo "ERROR: Failed to copy rke2 binary to ${BIN_DIR}"
        exit 1
    fi

    rm -rf "$TMP_DIR"

    echo "Starting $SERVICE_NAME service..."
    if systemctl start "$SERVICE_NAME"; then
        echo "Service started successfully"
        sleep 5
        if ! systemctl is-active --quiet "$SERVICE_NAME"; then
            echo "ERROR: Service started but is not active"
            ROLLBACK_NEEDED=true
        fi
    else
        echo "ERROR: Failed to start $SERVICE_NAME"
        ROLLBACK_NEEDED=true
    fi
}

rollback_changes() {
    echo "Initiating rollback due to failed upgrade..."
    
    # Stop service if running
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        systemctl stop "$SERVICE_NAME"
    fi
    
    # Rollback binary
    if [ -f "${BACKUP_BIN_DIR}/rke2.bak" ]; then
        echo "Restoring previous binary..."
        cp "${BACKUP_BIN_DIR}/rke2.bak" "${BIN_DIR}/rke2"
        chmod +x "${BIN_DIR}/rke2"
    else
        echo "WARNING: No binary backup found to restore"
    fi
    
    # Rollback images
    echo "Restoring previous images..."
    for img_backup in "${OLD_IMAGES_DIR}"/*.bak; do
        if [ -f "$img_backup" ]; then
            filename=$(basename "$img_backup" .bak)
            echo "Restoring $filename"
            cp "$img_backup" "${RKE2_IMAGES_DIR}/${filename}"
        fi
    done
    
    # Attempt to start service with old version
    echo "Attempting to start service with previous version..."
    if systemctl start "$SERVICE_NAME"; then
        echo "Rollback completed successfully"
    else
        echo "ERROR: Failed to start service after rollback. Manual intervention required."
        exit 1
    fi
}

# Main execution flow
echo "Starting RKE2 upgrade process for version $CURRENT_VERSION"

# Step 1: Verify checksums
verify_checksums

# Step 2: Backup etcd (server nodes only)
backup_etcd

# Step 3: Backup old binary
backup_old_binary

# Step 4: Backup old images
backup_old_images

# Step 5: Deploy new images
deploy_new_images

# Step 6: Deploy new binary
deploy_new_binary

# Check if rollback is needed
if $ROLLBACK_NEEDED; then
    rollback_changes
    exit 1
fi

echo "RKE2 upgrade process completed successfully"
exit 0
