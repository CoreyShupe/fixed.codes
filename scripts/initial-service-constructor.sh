#!/bin/bash

SERVICES=[]
for file in $(ls .); do
  if [ -d $file ]; then
    if [ -e $file/build_template.json ]; then
      SERVICES=$(echo $SERVICES | jq -c ". += [\"$file\"]")
    fi
  fi
done

echo $SERVICES | jq -c .
