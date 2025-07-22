#!/bin/bash

# compress_my_photos.sh - Recursive JPEG compression script
# Usage: ./compress_my_photos.sh [compression_command]
# If no compression command is provided, it will use a default jpegoptim command

set -euo pipefail

# Configuration
SCRIPT_NAME="compress_my_photos.sh"
LOG_FILE="compress_my_photos.log"
START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
PROCESSED_FOLDERS=()
UNPROCESSED_FOLDERS=()
SUCCESS_COUNT=0
ERROR_COUNT=0
TOTAL_FILES=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default compression command (modify as needed)
DEFAULT_COMPRESS_CMD="jpegoptim --max=85 --preserve --strip-all"

# Get compression command from argument or use default
COMPRESS_CMD="${1:-$DEFAULT_COMPRESS_CMD}"

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Progress bar function
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\rProgress: ["
    printf "%*s" $filled | tr ' ' '='
    printf "%*s" $empty | tr ' ' '-'
    printf "] %d%% (%d/%d)" $percentage $current $total
}

# Error handling function
handle_error() {
    local error_msg="$1"
    local folder="$2"
    echo -e "${RED}ERROR in $folder: $error_msg${NC}"
    log_message "ERROR" "$folder: $error_msg"
    ERROR_COUNT=$((ERROR_COUNT + 1))
}

# Success handling function
handle_success() {
    local folder="$1"
    local file_count="$2"
    echo -e "${GREEN}SUCCESS: $folder ($file_count files processed)${NC}"
    log_message "SUCCESS" "$folder: $file_count files processed"
    PROCESSED_FOLDERS+=("$folder")
    SUCCESS_COUNT=$((SUCCESS_COUNT + file_count))
}

# Check if compression tool is available
check_compression_tool() {
    local tool=$(echo "$COMPRESS_CMD" | awk '{print $1}')
    if ! command -v "$tool" &> /dev/null; then
        log_message "CRITICAL" "Compression tool '$tool' is not installed or not in PATH"
        echo -e "${RED}CRITICAL ERROR: '$tool' not found. Please install it first.${NC}"
        exit 1
    fi
    log_message "INFO" "Using compression command: $COMPRESS_CMD"
}

# Count total JPEG files for progress tracking
count_jpeg_files() {
    local count=0
    while IFS= read -r -d '' folder; do
        local folder_files=$(find "$folder" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) | wc -l)
        count=$((count + folder_files))
    done < <(find . -type d -print0)
    echo $count
}

# Process a single folder
process_folder() {
    local folder="$1"
    local folder_files=()
    local folder_success=0
    local folder_errors=0
    
    # Find JPEG files in current folder only (not recursive)
    while IFS= read -r -d '' file; do
        folder_files+=("$file")
    done < <(find "$folder" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -print0)
    
    # Skip if no JPEG files found
    if [ ${#folder_files[@]} -eq 0 ]; then
        return 0
    fi
    
    echo -e "${BLUE}Processing folder: $folder (${#folder_files[@]} files)${NC}"
    log_message "INFO" "Processing folder: $folder (${#folder_files[@]} files)"
    
    # Process each file
    for file in "${folder_files[@]}"; do
        local filename=$(basename "$file")
        printf "  Processing: %s... " "$filename"
        
        # Create backup of original file size for comparison
        local original_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        
        # Execute compression command
        if eval "$COMPRESS_CMD \"$file\"" >> "$LOG_FILE" 2>&1; then
            local new_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
            local saved_bytes=$((original_size - new_size))
            local saved_percent=0
            if [ $original_size -gt 0 ]; then
                saved_percent=$((saved_bytes * 100 / original_size))
            fi
            
            echo -e "${GREEN}OK${NC} (saved: ${saved_bytes} bytes, ${saved_percent}%)"
            log_message "SUCCESS" "$file: saved $saved_bytes bytes ($saved_percent%)"
            folder_success=$((folder_success + 1))
            TOTAL_FILES=$((TOTAL_FILES + 1))
            show_progress $TOTAL_FILES $(count_jpeg_files)
        else
            echo -e "${RED}FAILED${NC}"
            handle_error "Failed to compress $filename" "$folder"
            folder_errors=$((folder_errors + 1))
        fi
    done
    
    # Record folder processing result
    if [ $folder_errors -eq 0 ]; then
        handle_success "$folder" "$folder_success"
    else
        UNPROCESSED_FOLDERS+=("$folder (errors: $folder_errors)")
        log_message "WARNING" "$folder: completed with $folder_errors errors"
    fi
}

# Main execution function
main() {
    # Initialize log file
    echo "=== JPEG Compression Log - Started at $START_TIME ===" > "$LOG_FILE"
    echo -e "${BLUE}=== JPEG Compression Script Started ===${NC}"
    echo -e "${BLUE}Compression command: $COMPRESS_CMD${NC}"
    echo -e "${BLUE}Log file: $LOG_FILE${NC}"
    echo
    
    # Check prerequisites
    check_compression_tool
    
    # Count total files for progress tracking
    echo "Scanning for JPEG files..."
    TOTAL_JPEG_FILES=$(count_jpeg_files)
    
    if [ $TOTAL_JPEG_FILES -eq 0 ]; then
        echo -e "${YELLOW}No JPEG files found in current directory and subdirectories.${NC}"
        log_message "INFO" "No JPEG files found"
        exit 0
    fi
    
    echo -e "${BLUE}Found $TOTAL_JPEG_FILES JPEG files to process${NC}"
    log_message "INFO" "Found $TOTAL_JPEG_FILES JPEG files to process"
    echo
    
    # Process all folders
    local folder_count=0
    while IFS= read -r -d '' folder; do
        folder_count=$((folder_count + 1))
        process_folder "$folder"
    done < <(find . -type d -print0 | sort -z)
    
    echo
    echo
    
    # Generate summary
    local end_time=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${BLUE}=== PROCESSING COMPLETE ===${NC}"
    echo -e "${GREEN}Successfully processed folders:${NC}"
    
    if [ ${#PROCESSED_FOLDERS[@]} -eq 0 ]; then
        echo "  None"
    else
        for folder in "${PROCESSED_FOLDERS[@]}"; do
            echo "  ✓ $folder"
        done
    fi
    
    echo
    echo -e "${YELLOW}Folders with errors or not processed:${NC}"
    if [ ${#UNPROCESSED_FOLDERS[@]} -eq 0 ]; then
        echo "  None"
    else
        for folder in "${UNPROCESSED_FOLDERS[@]}"; do
            echo "  ✗ $folder"
        done
    fi
    
    echo
    echo -e "${BLUE}Summary:${NC}"
    echo "  Total files processed successfully: $SUCCESS_COUNT"
    echo "  Total files with errors: $ERROR_COUNT"
    echo "  Total folders processed: ${#PROCESSED_FOLDERS[@]}"
    echo "  Total folders with errors: ${#UNPROCESSED_FOLDERS[@]}"
    echo "  Started: $START_TIME"
    echo "  Completed: $end_time"
    
    # Log summary
    log_message "SUMMARY" "Processing complete - Success: $SUCCESS_COUNT files, Errors: $ERROR_COUNT files"
    log_message "SUMMARY" "Processed folders: ${#PROCESSED_FOLDERS[@]}, Error folders: ${#UNPROCESSED_FOLDERS[@]}"
    echo "=== JPEG Compression Log - Completed at $end_time ===" >> "$LOG_FILE"
    
    echo
    echo -e "${BLUE}Detailed log saved to: $LOG_FILE${NC}"
}

# Script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Trap to handle script interruption
    trap 'echo -e "\n${RED}Script interrupted by user${NC}"; log_message "ERROR" "Script interrupted by user"; exit 130' INT
    
    # Run main function
    main "$@"
fi

