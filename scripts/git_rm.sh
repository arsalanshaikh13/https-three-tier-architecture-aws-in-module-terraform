#!/bin/bash

# Define the array of files to remove from the index
remove=(
    "terraform_dev/compute/asg/client_panda.sh"
    "terraform_dev/compute/asg/server_panda.sh"
    "terraform_prod/compute/asg/client_panda.sh"
    "terraform_prod/compute/asg/server_panda.sh"
)

# Loop through each item in the array
for file_path in "${remove[@]}"; do
    echo "Running: git rm --cached \"$file_path\""
    
    # Execute the command
    git rm --cached "$file_path"
    
    # Optional: Check if the command was successful
    if [ $? -eq 0 ]; then
        echo "Successfully removed $file_path from the index."
    else
        echo "Failed to remove $file_path. Check if the file exists and is tracked."
    fi
    echo "---"
done

echo "Loop finished."
