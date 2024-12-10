#!/bin/bash
#
# Copyright (C) 2024, NikitaY
# me @ nikitay.com
# All Rights Reserved.
#
# This script extracts shutter counter information from Canon cameras using gphoto2 library.
#

# Display a banner
echo -e "\033[36m"
echo "##############################################################"
echo "#                                                            #"
echo "#             Shutter Counter Extraction Script              #"
echo "#                  NikitaY (C) December 2024                 #"
echo "#     GitHub: https://github.com/nikitaycs50/foto-tools/     #"
echo "#                                                            #"
echo "##############################################################"
echo -e "\033[0m"
echo

# Check if gphoto2 is installed
if ! command -v gphoto2 &> /dev/null; then
    echo "Error: gphoto2 is not installed. Please install it using the instructions below:"
    echo ""
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "On macOS: Run 'brew install gphoto2'"
        echo "Ensure Homebrew is installed: https://brew.sh"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "On Linux: Run 'sudo apt update && sudo apt install gphoto2'"
        echo "For other distributions, refer to: https://gphoto.org/"
    else
        echo "Unsupported OS. Please refer to: https://gphoto.org/"
    fi
    exit 1
fi

# Default TTL and retry interval
DEFAULT_TTL=60          # 1 minute (60 seconds)
RETRY_INTERVAL=2        # Retry every 2 seconds

# Usage function
usage() {
    echo "Usage: $0 [-w] [-t TTL]"
    echo ""
    echo "Options:"
    echo "  -w               Wait for the camera to connect, retrying every 2 seconds."
    echo "  -t TTL           Timeout in seconds (default: 60 seconds)."
    echo "  -h               Show this help message."
    echo ""
    exit 0
}

# Variables
wait_for_camera=false
ttl=$DEFAULT_TTL

# Parse arguments
while getopts "wht:" opt; do
    case $opt in
        w)
            wait_for_camera=true
            ;;
        t)
            ttl=$OPTARG
            if ! [[ $ttl =~ ^[0-9]+$ ]]; then
                echo "Error: TTL must be a positive integer."
                exit 1
            fi
            ;;
        h)
            usage
            ;;
        *)
            echo "Invalid option: -$OPTARG"
            usage
            ;;
    esac
done

# Function to detect camera
detect_camera() {
    gphoto2 --auto-detect 2>/dev/null | grep -v -- "No camera found" | grep -v -- '----------------'
}

# Function to get shutter count
get_shutter_count() {
    local shutter_count
    shutter_count=$(gphoto2 --get-config /main/status/shuttercounter 2>/dev/null | grep "Current:" | awk -F': ' '{print $2}')
    if [[ -z $shutter_count ]]; then
        echo "Error: Unable to retrieve shutter count. Ensure your camera supports this feature."
        return 1
    fi
    echo "Shutter Count: $shutter_count"
    return 0
}

# Main logic
if $wait_for_camera; then
    echo "Waiting for camera to connect... (TTL: $ttl seconds, Retry Interval: $RETRY_INTERVAL seconds)"
    elapsed=0
    while [[ $elapsed -lt $ttl ]]; do
        if detect_camera; then
            echo "Camera detected:"
            detect_camera
            if get_shutter_count; then
                exit 0
            fi
        fi

        echo "No camera detected or unable to retrieve shutter count. Retrying in $RETRY_INTERVAL seconds..."
        sleep $RETRY_INTERVAL
        ((elapsed+=RETRY_INTERVAL))
    done

    echo "Error: Camera not detected within the TTL period."
    exit 1
else
    echo "Checking for connected camera..."
    if detect_camera; then
        echo "Camera detected:"
        detect_camera
        if ! get_shutter_count; then
            echo "Error: Unable to retrieve shutter count. Ensure your camera supports this feature."
            exit 1
        fi
    else
        echo "Error: No camera detected. Please connect your camera and try again."
        exit 1
    fi
fi
