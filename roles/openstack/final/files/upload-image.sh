#!/bin/bash

image_name=$1
image_path=$2

# This method lacks progress bar.
openstack image create $image_name \
    --container-format bare \
    --disk-format raw \
    --file $image_path \
    --public

:<< EOF
glance image-create \
    --progress \
    --name $image_name \
    --disk-format raw \
    --container-format bare \
    --visibility public \
    --protected true \
    --file $image_path
EOF