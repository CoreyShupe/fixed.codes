#!/bin/bash

SERVICES=[]
for file in $(ls .); do
  if [ -d $file ]; then
    if [ -e $file/build_template.json ]; then
      $SERVICES=$(jq -c ". += [\"$file\"]" <<< $SERVICES)
    fi
  fi
done

jq -c . <<< $SERVICES
