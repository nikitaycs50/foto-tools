
# JPG EXIF Data Analysis and Histogram Plotter

A Bash script that parses JPG files in a specified directory to extract and analyze EXIF data for **Aperture**, **Focal Length**, and **ISO**. It generates a summary table with minimum, maximum, and average values, followed by colored text-based histograms for each metric.

## Features

- Extracts EXIF data (Aperture, Focal Length, and ISO) from JPG files.
- Calculates and displays:
  - **Minimum Value**
  - **Maximum Value**
  - **Average Value**
- Generates text-based histograms with bins and percentages.
- Highlights the average value in each histogram.
- Skips bins with zero data for cleaner output.
- Colored output for better readability.

## Prerequisites

1. **macOS/Linux**: The script is designed to run on UNIX-based systems.
2. **Install exiftool**:
   - On macOS: `brew install exiftool`
   - On Linux: Use your package manager, e.g., `sudo apt install exiftool`.

## Usage

1. Clone the repository or download the script.
2. Make the script executable:
   ```bash
   chmod +x exif_stats.sh
   ```
3. Run the script, providing the path to the folder containing JPG files:
   ```bash
   ./exif_stats.sh <path_to_folder_with_jpgs>
   ```
   Example:
   ```bash
   ./exif_stats.sh ~/Downloads/FOTO/Shutterstock
   ```

## Example Output

```
##############################################################
#                                                            #
#       JPG EXIF Data Analysis and Histogram Plotter         #
#          Analyze Aperture, Focal Length, and ISO           #
#                                                            #
##############################################################

Summary Table:
Apertures:
  Min: 1.4
  Max: 22.6
  Avg: 6.35323

Focal Lengths:
  Min: 17.0
  Max: 200.0
  Avg: 60.8387

ISOs:
  Min: 100
  Max: 3200
  Avg: 428.768

Aperture Distribution (Bin width: 2.12):
  1.40 -   3.52: ################################################## (30.65%)
  3.52 -   5.64: ################## (11.29%)
  5.64 -   7.76: ####################### << AVG=6.35323 (14.52%)
  7.76 -   9.88: ############################################### (29.03%)
  9.88 -  12.00: ################## (11.29%)
 14.12 -  16.24: ## (1.61%)

Focal Length Distribution (Bin width: 18.3):
 17.00 -  35.30: ############################ (27.42%)
 35.30 -  53.60: ################################################## (48.39%)
 53.60 -  71.90: ##### << AVG=60.8387 (4.84%)
 90.20 - 108.50: ########### (11.29%)
145.10 - 163.40: # (1.61%)

ISO Distribution (Bin width: 310):
100.00 - 410.00: ################################################## (86.96%)
720.00 - 1030.00: # (2.90%)
1340.00 - 1650.00: # (2.90%)
2270.00 - 2580.00: ## (1.45%)

Analysis Complete! Thank you for using this script.
```

![Example Output](https://github.com/nikitaycs50/foto-tools/EXIF/EXIF-Output-Example.png)

## Notes

- **Empty Bins**: Bins with no data are omitted to avoid clutter and ensure accurate averages.
- **Adjustable Bins**: The number of bins for histograms can be adjusted in the script.

## License

**NikitaY (C) 2024, December**  
GitHub: [https://github.com/nikitaycs50/foto-tools/](https://github.com/nikitaycs50/foto-tools/)
