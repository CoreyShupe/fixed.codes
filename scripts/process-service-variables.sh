#!/bin/bash

HANDLE_PATH=$1

echo -n helm_chart=
jq -r '.helm_chart' $HANDLE_PATH
echo -n ingress_prefix=
jq -r '.ingress_prefix' $HANDLE_PATH
echo -n service_port=
jq -r '.service_port' $HANDLE_PATH
echo -n target_port=
jq -r '.target_port' $HANDLE_PATH
echo -n service_type=
jq -r '.service_type' $HANDLE_PATH
echo -n language=
jq -r '.language' $HANDLE_PATH
