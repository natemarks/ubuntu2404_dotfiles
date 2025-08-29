#!/usr/bin/env bash

# Define the substring to search for in image IDs
substring="${1}"

# Get a list of all image IDs
image_ids=$(docker images -q)

# Loop through each image ID
for id in $image_ids; do
    # Check if the image ID contains the given substring
    if docker inspect --format='{{json .RepoTags}}' $id | grep -q "$substring"; then
        echo "Image ID $id contains the substring '$substring'"
        # Prune the image
        docker rmi -f $id
        echo "Image ID $id pruned"
    fi
done
