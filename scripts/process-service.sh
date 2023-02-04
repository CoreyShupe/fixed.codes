#!/bin/bash

# This script simply processes a template; generating the output file
# and removing/checking the path detections as a result

rm -rf outputs/*

jq -c "del(.path_detections)" $1/$2 > outputs/$1.json

# Send the path detections up the line for vis
echo -n detections=
jq -c ".path_detections" $1/$2
