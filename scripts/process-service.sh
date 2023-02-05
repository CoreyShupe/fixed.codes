#!/bin/bash

# This script simply processes a template; generating the output file
# and removing/checking the path detections as a result

mkdir -p outputs
rm -rf outputs/*

jq -c "del(.path_detections)" $1/$2 > outputs/$1.json

function process_detection {
  if [ -d $1 ]; then
    find $1 -print0 | while IFS= read -r -d '' file
    do
      if [ ! -d $file ]; then
        echo "  - \"$file\"" >> outputs/$2.yaml
      fi
    done
  else
    echo "  - \"$1\"" >> outputs/$2.yaml
  fi

}

touch outputs/$1.yaml
echo "deps:" > outputs/$1.yaml

process_detection $1 $1
process_detection "deploy/$(jq -r '.language' $1/$2).Dockerfile" $1

for service in $(jq -r ".services[]" $1/$2 | sed -e 's/*/\\*/g'); do
  process_detection "services/$service.Dockerfile" $1
done

for detection in $(jq -r ".path_detections[]" $1/$2); do
  process_detection $detection $1
done

echo "Detections Processing:"
cat outputs/$1.yaml
