#!/usr/bin/env bash

# Discloud Project Packer Script
# This script creates a clean zip file ready for Discloud deployment

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="eruditus-bot"
OUTPUT_FILE="${PROJECT_NAME}-discloud.zip"
TEMP_DIR="./discloud_build_temp"

echo -e "${GREEN}Starting Discloud packaging...${NC}"

# Clean up any previous build
if [ -f "$OUTPUT_FILE" ]; then
    echo -e "${YELLOW}Removing existing package: $OUTPUT_FILE${NC}"
    rm "$OUTPUT_FILE"
fi

if [ -d "$TEMP_DIR" ]; then
    echo -e "${YELLOW}Cleaning up temporary directory...${NC}"
    rm -rf "$TEMP_DIR"
fi

# Create temporary directory
echo -e "${GREEN}Creating temporary build directory...${NC}"
mkdir -p "$TEMP_DIR"

# Copy project files, excluding unnecessary items
echo -e "${GREEN}Copying project files...${NC}"
rsync -av \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='*.pyo' \
    --exclude='.git' \
    --exclude='.gitignore' \
    --exclude='.env' \
    --exclude='*.log' \
    --exclude='docker-compose.yml' \
    --exclude='Dockerfile' \
    --exclude='.dockerignore' \
    --exclude='*.md' \
    --exclude='LICENSE' \
    --exclude='.vscode' \
    --exclude='.idea' \
    --exclude='*.egg-info' \
    --exclude='dist' \
    --exclude='build' \
    --exclude="$OUTPUT_FILE" \
    --exclude="$TEMP_DIR" \
    ./ "$TEMP_DIR/"

# Verify required files exist
echo -e "${GREEN}Verifying required files...${NC}"
REQUIRED_FILES=("discloud.config" "requirements.txt" "eruditus/eruditus.py")
MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$TEMP_DIR/$file" ]; then
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo -e "${RED}Error: Missing required files:${NC}"
    printf '%s\n' "${MISSING_FILES[@]}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Display discloud.config contents
echo -e "${GREEN}Discloud configuration:${NC}"
cat "$TEMP_DIR/discloud.config"
echo ""

# Create the zip file
echo -e "${GREEN}Creating zip package...${NC}"
cd "$TEMP_DIR"
zip -r "../$OUTPUT_FILE" . -x "*.DS_Store"
cd ..

# Clean up temporary directory
echo -e "${GREEN}Cleaning up temporary files...${NC}"
rm -rf "$TEMP_DIR"

# Display results
FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
echo -e "${GREEN}✓ Package created successfully!${NC}"
echo -e "${GREEN}  File: $OUTPUT_FILE${NC}"
echo -e "${GREEN}  Size: $FILE_SIZE${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Upload $OUTPUT_FILE to https://discloud.com/dashboard/app/1764574529144"
echo "2. Ensure your environment variables are set in Discloud dashboard"
echo "3. Deploy and monitor logs for any issues"
echo ""
echo -e "${GREEN}Happy deploying! 🚀${NC}"
