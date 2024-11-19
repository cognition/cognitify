#!/bin/bash
## (C) 2024
## Ramon Brooker <rbrooker@aeo3.io>

# Define source directories
SRC_DIR="src/bash.bashrc.d"
HOME_FILES_SRC="src/home-files"
COMPLETIONS_SRC="src/completions"
PACKAGES_DIR="src/packages"

# Define destination directories
DEST_DIR="/etc"
COMPLETIONS_DEST="/etc/bash_completion.d"
USER_HOME="$HOME"

# Group name
GROUP_NAME="cognitify"

# Function to determine the distro name
get_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif command -v lsb_release >/dev/null 2>&1; then
        lsb_release -si | tr '[:upper:]' '[:lower:]'
    else
        uname -s | tr '[:upper:]' '[:lower:]'
    fi
}

# Get the current distribution name
DISTRO=$(get_distro)

echo "Detected distribution: $DISTRO"

# Check if the package list file for the distro exists
PACKAGE_FILE="$PACKAGES_DIR/$DISTRO-packages.txt"
if [ ! -f "$PACKAGE_FILE" ]; then
    echo "Warning: Package list for distribution '$DISTRO' not found. Continuing without package installation."
else
    # Install packages listed in the distribution-specific file
    echo "Installing packages listed in '$PACKAGE_FILE'..."
    if command -v apt-get >/dev/null 2>&1; then
        xargs -a "$PACKAGE_FILE" sudo apt-get install -y
    elif command -v yum >/dev/null 2>&1; then
        xargs -a "$PACKAGE_FILE" sudo yum install -y
    elif command -v dnf >/dev/null 2>&1; then
        xargs -a "$PACKAGE_FILE" sudo dnf install -y
    elif command -v zypper >/dev/null 2>&1; then
        xargs -a "$PACKAGE_FILE" sudo zypper install -y
    else
        echo "Error: Package manager not supported on this system."
        exit 1
    fi
fi

# Check and prepare directories
if [ ! -d "$SRC_DIR" ]; then
    echo "Error: Source directory '$SRC_DIR' does not exist."
    exit 1
fi

if [ ! -d "$HOME_FILES_SRC" ]; then
    echo "Error: Source directory '$HOME_FILES_SRC' does not exist."
    exit 1
fi

if [ ! -d "$COMPLETIONS_SRC" ]; then
    echo "Error: Source directory '$COMPLETIONS_SRC' does not exist."
    exit 1
fi

# Create group if it doesn't exist
if ! getent group "$GROUP_NAME" >/dev/null; then
    echo "Creating group '$GROUP_NAME'..."
    if ! groupadd "$GROUP_NAME"; then
        echo "Error: Failed to create group '$GROUP_NAME'."
        exit 1
    fi
else
    echo "Group '$GROUP_NAME' already exists."
fi

# Add the current user to the group
USER=$(whoami)
echo "Adding user '$USER' to group '$GROUP_NAME'..."
if ! usermod -aG "$GROUP_NAME" "$USER"; then
    echo "Error: Failed to add user '$USER' to group '$GROUP_NAME'."
    exit 1
fi

# Make necessary directories if they do not exist
DEST_PATH="$DEST_DIR/$SRC_DIR"
if [ ! -d "$DEST_PATH" ]; then
    echo "Creating directory '$DEST_PATH'..."
    if ! mkdir -p "$DEST_PATH"; then
        echo "Error: Failed to create directory '$DEST_PATH'."
        exit 1
    fi
fi

if [ ! -d "$COMPLETIONS_DEST" ]; then
    echo "Creating directory '$COMPLETIONS_DEST'..."
    if ! mkdir -p "$COMPLETIONS_DEST"; then
        echo "Error: Failed to create directory '$COMPLETIONS_DEST'."
        exit 1
    fi
fi

# Copy files from the source directory to the destination directory
echo "Copying files from '$SRC_DIR' to '$DEST_PATH'..."
if ! cp -R "$SRC_DIR/" "$DEST_PATH"; then
    echo "Error: Failed to copy files."
    exit 1
fi

# Set ownership to root:cognitify and permissions to group read/write
echo "Setting directory ownership and permissions..."
if ! chown -R root:"$GROUP_NAME" "$DEST_PATH"; then
    echo "Error: Failed to set ownership."
    exit 1
fi

if ! chmod -R 775 "$DEST_PATH"; then
    echo "Error: Failed to set permissions."
    exit 1
fi

# Copy completion files to the /etc/bash_completion.d/ directory
echo "Copying completion files from '$COMPLETIONS_SRC' to '$COMPLETIONS_DEST'..."
if ! cp -R "$COMPLETIONS_SRC/." "$COMPLETIONS_DEST"; then
    echo "Error: Failed to copy completion files."
    exit 1
fi

# Copy home-files to the current user's home directory
echo "Processing files from '$HOME_FILES_SRC' to '$USER_HOME'..."

for file in "$HOME_FILES_SRC"/*; do
    # Extract the filename and add the dot prefix
    filename=$(basename "$file")
    hidden_filename=".$filename"
    dest_file="$USER_HOME/$hidden_filename"
    
    # Check if the destination file exists
    if [ -f "$dest_file" ]; then
        echo "File '$hidden_filename' already exists in your home directory."

        # Prompt for confirmation
        read -p "Do you want to overwrite it? (y/n) (Backup original as .orig): " choice

        if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
            # Backup the original file
            cp "$dest_file" "${dest_file}.orig"
            echo "Original file backed up as '${dest_file}.orig'."
            
            # Copy the new file
            cp "$file" "$dest_file"
            echo "File '$hidden_filename' has been overwritten."
        else
            echo "Skipped overwriting '$hidden_filename'."
        fi
    else
        cp "$file" "$dest_file"
        echo "File '$hidden_filename' has been copied."
    fi
done

echo "Installation completed successfully."