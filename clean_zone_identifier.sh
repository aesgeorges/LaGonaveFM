#!/bin/bash

# Bash script to recursively delete all Zone.Identifier files
# These files are created by Windows when downloading files from the internet

# Default values
TARGET_DIR="."
DRY_RUN=false
FORCE=false

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS] [DIRECTORY]"
    echo ""
    echo "Options:"
    echo "  -d, --dry-run    Show what would be deleted without actually deleting"
    echo "  -f, --force      Delete without confirmation prompt"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                          # Clean current directory"
    echo "  $0 /path/to/directory       # Clean specific directory"
    echo "  $0 --dry-run ~/Downloads    # Preview what would be deleted"
    echo "  $0 --force ~/Downloads      # Delete without confirmation"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# Check if directory exists
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

# Convert to absolute path
TARGET_DIR=$(realpath "$TARGET_DIR")

echo "Searching for Zone.Identifier files in: $TARGET_DIR"

# Find all Zone.Identifier files recursively
# Using both common patterns: *:Zone.Identifier and *Zone.Identifier
mapfile -t zone_files < <(find "$TARGET_DIR" -type f \( -name "*:Zone.Identifier" -o -name "*Zone.Identifier" \) 2>/dev/null)

if [[ ${#zone_files[@]} -eq 0 ]]; then
    echo "No Zone.Identifier files found."
    exit 0
fi

echo "Found ${#zone_files[@]} Zone.Identifier files:"

# Display files that will be deleted
for file in "${zone_files[@]}"; do
    echo "  $file"
done

if [[ "$DRY_RUN" == true ]]; then
    echo ""
    echo "[DRY RUN] Files listed above would be deleted."
    exit 0
fi

# Confirm deletion unless force flag is used
if [[ "$FORCE" != true ]]; then
    echo ""
    read -p "Do you want to delete these files? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        exit 0
    fi
fi

# Delete files
deleted_count=0
failed_count=0

for file in "${zone_files[@]}"; do
    if rm "$file" 2>/dev/null; then
        echo "Deleted: $file"
        ((deleted_count++))
    else
        echo "Failed to delete: $file"
        ((failed_count++))
    fi
done

echo ""
echo "Successfully deleted $deleted_count out of ${#zone_files[@]} files."
if [[ $failed_count -gt 0 ]]; then
    echo "Failed to delete $failed_count files."
fi