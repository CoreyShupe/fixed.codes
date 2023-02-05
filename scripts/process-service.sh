#!/bin/bash

# This script simply processes a template; generating the output file
# and removing/checking the path detections as a result

rm -rf outputs/*

jq -c "del(.path_detections)" $1/$2 > outputs/$1.json

touch outputs/$1.yaml
echo "deps:" > outputs/$1.yaml
for detection in $(jq -r ".path_detections[]" $1/$2); do
  echo "  - \"$detection\"" >> outputs/$1.yaml
done

echo "Detections Processing:"
cat outputs/$1.yaml
