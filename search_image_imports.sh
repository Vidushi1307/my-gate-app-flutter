#!/bin/bash

# Check if two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_directory> <target_directory>"
    exit 1
fi

source_dir="$1"
target_dir="$2"

# Verify directories exist
if [ ! -d "$source_dir" ]; then
    echo "Error: Source directory '$source_dir' does not exist"
    exit 1
fi

if [ ! -d "$target_dir" ]; then
    echo "Error: Target directory '$target_dir' does not exist"
    exit 1
fi

# Get list of files from source directory
files=$(ls "$source_dir")

# Loop through each file and grep in target directory
for file in $files; do
    echo "Searching for '$file' in '$target_dir'..."
    grep -r "$file" "$target_dir"
    echo "-------------------------------------------------------------------------------------------------------------------------"
done
