#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <number_of_characters_to_delete> <file>"
    exit 1
fi

# Number of characters to delete
n=$1

# File to process
file=$2

# Use sed to delete the first n characters of each line
sed -i "s/^.\{${n}\}//" "$file"

