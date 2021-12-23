#!/bin/bash
#
# USAGE ./rebuild.sh dev|test
# Deletes old Docker images and rebuilds for TAG dev|test
tag="$1"
docker image rmi -f "umedia_solr:${tag}"; docker build . --tag "umedia_solr:${tag}" --no-cache
