# EXIF Stats Script

A simple Bash script to parse JPG files in a specified folder and calculate EXIF metadata statistics. The script extracts and computes the following:

- **Aperture**: Minimum, maximum, and average values.
- **Focal Length**: Minimum, maximum, and average values.

## Prerequisites

- **macOS** or any UNIX-based system with Bash.
- `exiftool` installed.

Install `exiftool` via Homebrew:
```bash
brew install exiftool
```

## Usage

```bash
./exif_stats.sh <path_to_folder_with_jpgs>
```

## Output Example
```yaml
Apertures:
  Min: 2.8
  Max: 16
  Avg: 5.6
Focal Lengths:
  Min: 24
  Max: 105
  Avg: 50.5
```

