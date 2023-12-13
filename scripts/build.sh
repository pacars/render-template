#!/bin/bash

rsync -av images public/
rsync -av render public/
rsync index.html render public/
ORGANIZATION=$1

sed -i "s/{{organization}}/$ORGANIZATION/g" "./public/index.html"