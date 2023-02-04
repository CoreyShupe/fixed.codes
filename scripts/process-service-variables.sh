#!/bin/bash

PATH=$1

echo -n helm_chart=
jq -r '.helm_chart' $PATH
echo -n ingress_prefix=
jq -r '.ingress_prefix' $PATH
echo -n service_port=
jq -r '.service_port' $PATH
echo -n target_port=
jq -r '.target_port' $PATH
echo -n service_type=
jq -r '.service_type' $PATH
echo -n language=
jq -r '.language' $PATH
