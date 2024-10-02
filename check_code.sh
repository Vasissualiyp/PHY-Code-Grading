#!/usr/bin/env bash

# This script checks that the code runs for each of the students

SUBM_DIR="./submissions"
output_csv="./allmarks.csv"

make_dirs=0
mark_assign=0
create_csv=1

student_names=$(ls -lA $SUBM_DIR | awk '{print $9}' | awk -F'_' '{print $1}' | uniq)

open_jupyter() {
    BROWSER=brave jupyter-notebook "$1" 1>/dev/null 2>/dev/null &
    JUPYTER_PID=$!  # Store the Jupyter process ID
    echo "Jupyter Notebook launched with PID: $JUPYTER_PID"
}

# Function to stop Jupyter Notebook
close_jupyter() {
    if [ -z "$JUPYTER_PID" ]; then
        echo "No Jupyter process ID found."
    else
        kill "$JUPYTER_PID"
        echo "Jupyter Notebook (PID: $JUPYTER_PID) has been closed."
        unset JUPYTER_PID
    fi
}

run_python() {
    rm -rf ./err.log
    python $1 2>./err.log && echo "Script $1 ran successfully" || \
			"Script $1 failed to run because of the following error:" && \
			cat ./err.log
}

run_and_check_python() {
    run_python $1
	vim $1
}

# Run python codes and notebooks
run_ipynbs_and_pys() {
	echo "Starting to run ipynbs..."
    rm -rf "./.ipynb_checkpoints"
    echo "Starting to open notebooks..."
    
# Find notebooks and properly handle spaces
find . -type f -name '*.ipynb' -print0 | while IFS= read -r -d '' j_notebook; do
    echo "Opening notebook '$j_notebook'..."
    open_jupyter "$j_notebook"
    
    # Wait for user input before closing
    echo "Press ENTER when you're done"
    # Redirect read input to /dev/tty to wait for user input
    read dummy < /dev/tty
    
    close_jupyter
    rm -rf "./.ipynb_checkpoints"
done
	echo "Starting to run pys..."
	#sleep 2
    python_files=$(find -type f -name '*.py')
	for file in $python_files; do
        run_and_check_python $file
	done
}

if [ $create_csv == 1 ]; then
    echo "ID,Mark" > "$output_file"
fi

# Move the students' files to their respective dirs
for name in $student_names; do
    echo "Student name: $name"
	#sleep 2
    if [ $make_dirs == 1 ]; then
        # Create a directory for the student if it doesn't exist
        mkdir -p "$SUBM_DIR/$name"
        
        # Move all files matching the student name into their directory
    	find "$SUBM_DIR" -type f -name "${name}_*" -exec mv {} "$SUBM_DIR/$name/" \;
    fi
    if [ $mark_assign == 1 ]; then
	    cd "$SUBM_DIR/$name" # Go into the dir of a student
        run_ipynbs_and_pys
	    echo "How satisfactory is the student's result? On a scale 0-2"
	    read mark
	    echo $mark > mark.txt
	    cd ../.. # Go back to the root dir
    fi
    if [ $create_csv == 1 ]; then
	    mark=$(cat "$SUBM_DIR/$name/mark.txt")
	    echo "$name,$mark" >> "$output_csv"
	fi
done

