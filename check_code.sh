#!/usr/bin/env bash

# This script checks that the code runs for each of the students

SUBM_DIR="./submissions"

student_names=$(ls -lA $SUBM_DIR | awk '{print $9}' | awk -F'_' '{print $1}' | uniq)

for name in $student_names; do
    # Create a directory for the student if it doesn't exist
    mkdir -p "$SUBM_DIR/$name"
    
    # Move all files matching the student name into their directory
    #mv "$SUBM_DIR/${name}_*" "$SUBM_DIR/$name/"
	find "$SUBM_DIR" -type f -name "${name}_*" -exec mv {} "$SUBM_DIR/$name/" \;

done
#echo $student_names
