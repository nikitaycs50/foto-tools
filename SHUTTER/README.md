
# Shutter Counter Extraction Script

A Bash script that connects to Canon cameras via USB, detects the camera, and retrieves the shutter counter value using the gphoto2 library. This script supports retries for detecting the camera and dynamic progress updates.

## Features

- Connects to Canon cameras via USB.
- Detects the connected camera and retrieves its model and port.
- Extracts the shutter counter value from supported Canon cameras.
- Supports retrying with a configurable timeout (TTL) and retry interval.
- Dynamically updates progress with retry count, elapsed time, and TTL on the same line.
- Provides clear instructions for resolving issues, such as missing prerequisites or unsupported cameras.
- Compatible with bash and zsh shells.

## Prerequisites

1. macOS/Linux: The script is designed to run on UNIX-based systems.
2. Install gphoto2:
- On macOS: brew install gphoto2
- On Linux: Use your package manager, e.g., sudo apt update && sudo apt install gphoto2

## Usage

1. Clone the repository or download the script.
2. Make the script executable:
   ```bash
   chmod +x shutter_count.sh
   ```
3. Run the script, providing the path to the folder containing JPG files:
   ```bash
   ./shutter_count.sh [options]
   ```
   ### Options: ###
    - -w: Wait for the camera to connect, retrying at a fixed interval.
    - -t TTL: Specify the timeout (in seconds) for retries when using -w. Default: 60 seconds.
    - -h: Display the help message.

4. Examples:
Check for a connected camera and retrieve the shutter count immediately:

```bash
./shutter_count.sh
```
Wait for the camera to connect with a default timeout of 60 seconds:

```bash
./shutter_count.sh -w
```
Wait for the camera with a custom timeout of 300 seconds:

```bash
./shutter_count.sh -w -t 300
```


## Example Output
```
##############################################################
#                                                            #
#             Shutter Counter Extraction Script              #
#                  NikitaY (C) December 2024                 #
#     GitHub: https://github.com/nikitaycs50/foto-tools/     #
#                                                            #
##############################################################

Waiting for camera to connect... (TTL: 60 seconds, Retry Interval: 2 seconds)
Retry #3 | Elapsed: 6s | TTL: 60s
Retry #4 | Elapsed: 8s | TTL: 60s
Retry #5 | Elapsed: 10s | TTL: 60s
Camera detected:
Model                          Port
Canon EOS 80D                  usb:001,005
Retrieving shutter count...
Shutter Count: 12345
```

## License

**NikitaY (C) 2024, December**  
GitHub: [https://github.com/nikitaycs50/foto-tools/](https://github.com/nikitaycs50/foto-tools/)
