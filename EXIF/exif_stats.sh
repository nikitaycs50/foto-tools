#!/bin/bash

# Ensure exiftool is installed
if ! command -v exiftool &>/dev/null; then
    echo "exiftool is not installed. Please install it with 'brew install exiftool'."
    exit 1
fi

# Check if a folder path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_folder_with_jpgs>"
    echo "Example: $0 /path/to/images"
    exit 1
fi

# Get the folder path
folder_path="$1"

# Check if the path exists and is a directory
if [ ! -d "$folder_path" ]; then
    echo "Error: The path '$folder_path' does not exist or is not a directory."
    exit 1
fi

# Initialize variables
apertures=()
focal_lengths=()

# Parse all JPG files in the specified directory
for file in "$folder_path"/*.jpg "$folder_path"/*.JPG; do
    if [ -f "$file" ]; then
        # Extract aperture and focal length
        aperture=$(exiftool -ApertureValue -s3 "$file")
        focal_length=$(exiftool -FocalLength -s3 "$file" | awk '{print $1}')

        # Add to arrays if values are numeric
        [[ $aperture =~ ^[0-9.]+$ ]] && apertures+=("$aperture")
        [[ $focal_length =~ ^[0-9.]+$ ]] && focal_lengths+=("$focal_length")
    fi
done

# Function to calculate min, max, and average
calculate_stats() {
    local values=("$@")
    local min max sum count avg
    min=$(printf '%s\n' "${values[@]}" | sort -n | head -n1)
    max=$(printf '%s\n' "${values[@]}" | sort -n | tail -n1)
    sum=$(printf '%s\n' "${values[@]}" | awk '{sum+=$1} END {print sum}')
    count=${#values[@]}
    avg=$(awk "BEGIN {print $sum / $count}")
    echo "$min $max $avg"
}

# Calculate stats for apertures
if [ ${#apertures[@]} -gt 0 ]; then
    aperture_stats=($(calculate_stats "${apertures[@]}"))
    echo "Apertures:"
    echo "  Min: ${aperture_stats[0]}"
    echo "  Max: ${aperture_stats[1]}"
    echo "  Avg: ${aperture_stats[2]}"
else
    echo "No aperture data found."
fi

# Calculate stats for focal lengths
if [ ${#focal_lengths[@]} -gt 0 ]; then
    focal_stats=($(calculate_stats "${focal_lengths[@]}"))
    echo "Focal Lengths:"
    echo "  Min: ${focal_stats[0]}"
    echo "  Max: ${focal_stats[1]}"
    echo "  Avg: ${focal_stats[2]}"
else
    echo "No focal length data found."
fi
