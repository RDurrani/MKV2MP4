#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_directory> <output_directory>"
    exit 1
fi

# Assign input and output directories from arguments
INPUT_DIRECTORY="$1"
OUTPUT_DIRECTORY="$2"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIRECTORY"

# Loop through each .mkv file in the input directory
for FILE in "$INPUT_DIRECTORY"/*.mkv; do
    if [ -f "$FILE" ]; then
        # Get the filename without the extension
        BASENAME=$(basename "$FILE" .mkv)
        
        # Define the output file paths
        OUTPUT_VIDEO="$OUTPUT_DIRECTORY/$BASENAME.mp4"
        OUTPUT_SUBTITLE="$OUTPUT_DIRECTORY/$BASENAME.srt"
        
        echo "Processing $FILE..."
        
        # Convert the video to HEVC format and copy the audio
        ffmpeg -i "$FILE" -c:v hevc -c:a copy "$OUTPUT_VIDEO"
        
        # Extract subtitles to .srt format
        ffmpeg -i "$FILE" -map 0:s:0 "$OUTPUT_SUBTITLE"
        
        # Remove <..> and {\an8} formatting from the .srt file
        sed -i 's/<[^>]*>//g' "$OUTPUT_SUBTITLE"
        sed -i 's/{\\an[0-9]}//g' "$OUTPUT_SUBTITLE"
        
        echo "Conversion complete: $OUTPUT_VIDEO"
        echo "Subtitle extraction complete: $OUTPUT_SUBTITLE"
    fi
done
echo "END"

