#!/bin/bash

# This script generates a diagram of the build services
# it uses outputs from a previous matrix run to determine
# which services need to be built and which micro-services
# need to be deployed.
#
# There's also a very concrete build order here; the services
# are built first as "dependencies" to the micro-services; one
# example is the RUST_WORKSPACE service which is a dependency to
# rust and elm resources. This workspace builds a bare docker
# container with the cargo workspaces' collected dependencies compiled.

SERVICE_OUTPUT="[]"
MICRO_SERVICE_OUTPUT="[]"

#!/bin/bash
for filename in outputs/*.json; do
  for service in $(jq -r '.services[]' $filename); do
    SERVICE_OUTPUT=$(jq -c --arg service "$service" '. + [$service]' <<< $SERVICE_OUTPUT)
  done

  runner=$(jq -r '.app_name' $filename)
  MICRO_SERVICE_OUTPUT=$(jq -c --arg runner "$runner" '. + [$runner]' <<< $MICRO_SERVICE_OUTPUT)
done

SERVICE_OUTPUT=$(jq -c 'unique' <<< $SERVICE_OUTPUT)

echo -n service_output=
jq -c . <<< $SERVICE_OUTPUT
echo -n micro_service_output=
jq -c . <<< $MICRO_SERVICE_OUTPUT
