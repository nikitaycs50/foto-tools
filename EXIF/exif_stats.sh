#!/bin/bash
#
# Copyright (c) 2024, Your Name
# All Rights Reserved.
#
# This script parses JPG files in a given directory to extract and analyze EXIF data
# for Aperture, Focal Length, and ISO. It generates statistical summaries and
# creates colored text-based bar charts.
#

# Ensure exiftool is installed
if ! command -v exiftool &>/dev/null; then
    echo -e "\033[31mError:\033[0m exiftool is not installed. Please install it with 'brew install exiftool'."
    exit 1
fi

# Display a banner
echo -e "\033[36m"
echo "##############################################################"
echo "#                                                            #"
echo "#       JPG EXIF Data Analysis and Histogram Plotter         #"
echo "#          Analyze Aperture, Focal Length, and ISO           #"
echo "#                  NikitaY (C) December 2024                 #"
echo "#     GitHub: https://github.com/nikitaycs50/foto-tools/     #"
echo "#                                                            #"
echo "##############################################################"
echo -e "\033[0m"
echo

# Check if a folder path is provided
if [ -z "$1" ]; then
    echo
    echo -e "\033[33mUsage:\033[0m $0 <path_to_folder_with_jpgs>"
    echo "Example: $0 /path/to/images"
    exit 1
fi

# Get the folder path
folder_path="$1"

# Check if the path exists and is a directory
if [ ! -d "$folder_path" ]; then
    echo
    echo -e "\033[31mError:\033[0m The path '$folder_path' does not exist or is not a directory."
    exit 1
fi

# Initialize variables
focal_lengths=()
apertures=()
isos=()

# Parse all JPG files in the specified directory
for file in "$folder_path"/*.jpg "$folder_path"/*.JPG; do
    if [ -f "$file" ]; then
        # Extract focal length, aperture, and ISO
        focal_length=$(exiftool -FocalLength -s3 "$file" | awk '{print $1}')
        aperture=$(exiftool -ApertureValue -s3 "$file")
        iso=$(exiftool -ISO -s3 "$file")

        # Add to respective arrays if the values are numeric
        [[ $focal_length =~ ^[0-9.]+$ ]] && focal_lengths+=("$focal_length")
        [[ $aperture =~ ^[0-9.]+$ ]] && apertures+=("$aperture")
        [[ $iso =~ ^[0-9]+$ ]] && isos+=("$iso")
    fi
done

# Function to calculate min, max, and average
calculate_stats() {
    local values=("$@")
    local min=$(printf "%s\n" "${values[@]}" | sort -n | head -n1)
    local max=$(printf "%s\n" "${values[@]}" | sort -n | tail -n1)
    local sum=$(printf "%s\n" "${values[@]}" | awk '{s+=$1} END {print s}')
    local count=${#values[@]}
    local avg=$(awk "BEGIN {print $sum / $count}")
    echo "$min $max $avg"
}

# Function to create histogram
create_histogram() {
    local values=("$@")
    local title=$1
    local bins=$2
    shift 2
    local values=("$@")

    local min=$(printf "%s\n" "${values[@]}" | sort -n | head -n1)
    local max=$(printf "%s\n" "${values[@]}" | sort -n | tail -n1)
    local bin_width=$(awk "BEGIN {print ($max - $min) / $bins}")
    local bin_starts=()
    local bin_counts=()
    for ((i=0; i<bins; i++)); do
        bin_starts+=($(awk "BEGIN {print $min + $i * $bin_width}"))
        bin_counts+=(0)
    done

    # Populate histogram
    for value in "${values[@]}"; do
        for ((i=0; i<bins; i++)); do
            local lower_bound=${bin_starts[i]}
            local upper_bound=$(awk "BEGIN {print $lower_bound + $bin_width}")
            if (( $(awk "BEGIN {print ($value >= $lower_bound && $value < $upper_bound)}") )); then
                bin_counts[i]=$((bin_counts[i] + 1))
                break
            fi
        done
    done

    # Calculate total and average
    local total_photos=${#values[@]}
    local average=$(calculate_stats "${values[@]}" | awk '{print $3}')

    # Plot the histogram
    echo -e "\033[36m$title Distribution (Bin width: $bin_width):\033[0m"
    local max_count=$(printf "%s\n" "${bin_counts[@]}" | sort -nr | head -n1)
    local scale=$(awk "BEGIN {print $max_count / 50}") # Scale for bar chart width
    for ((i=0; i<bins; i++)); do
        local lower_bound=${bin_starts[i]}
        local upper_bound=$(awk "BEGIN {print $lower_bound + $bin_width}")
        local count=${bin_counts[i]}

        # Skip bins with zero count
        if [ "$count" -eq 0 ]; then
            continue
        fi

        local percentage=$(awk "BEGIN {printf \"%.2f\", ($count / $total_photos) * 100}")
        local scaled_count=$(awk "BEGIN {printf \"%d\", $count / $scale}")
        local bar=$(printf "%0.s#" $(seq 1 "$scaled_count"))

        if (( $(awk "BEGIN {print ($average >= $lower_bound && $average < $upper_bound)}") )); then
            echo -e "$(printf "%6.2f" "$lower_bound") - $(printf "%6.2f" "$upper_bound"): \033[32m$bar << AVG=$average ($percentage%)\033[0m"
        else
            echo "$(printf "%6.2f" "$lower_bound") - $(printf "%6.2f" "$upper_bound"): $bar ($percentage%)"
        fi
    done
    echo
}

# Calculate and display statistics
echo -e "\033[34mSummary Table:\033[0m"
if [ ${#apertures[@]} -gt 0 ]; then
    read -r min max avg <<< $(calculate_stats "${apertures[@]}")
    echo -e "\033[35mApertures (f):\033[0m"
    echo "  Min: $min"
    echo "  Max: $max"
    echo "  Avg: $avg"
    echo
fi

if [ ${#focal_lengths[@]} -gt 0 ]; then
    read -r min max avg <<< $(calculate_stats "${focal_lengths[@]}")
    echo -e "\033[35mFocal Lengths (mm):\033[0m"
    echo "  Min: $min"
    echo "  Max: $max"
    echo "  Avg: $avg"
    echo
fi

if [ ${#isos[@]} -gt 0 ]; then
    read -r min max avg <<< $(calculate_stats "${isos[@]}")
    echo -e "\033[35mISOs:\033[0m"
    echo "  Min: $min"
    echo "  Max: $max"
    echo "  Avg: $avg"
    echo
fi

# Plot histograms
if [ ${#apertures[@]} -gt 0 ]; then
    create_histogram "Aperture (f)" 10 "${apertures[@]}"
fi

if [ ${#focal_lengths[@]} -gt 0 ]; then
    create_histogram "Focal Length (mm)" 10 "${focal_lengths[@]}"
fi

if [ ${#isos[@]} -gt 0 ]; then
    create_histogram "ISO" 10 "${isos[@]}"
fi

echo -e "\033[32mAnalysis Complete! Thank you for using this script.\033[0m"
