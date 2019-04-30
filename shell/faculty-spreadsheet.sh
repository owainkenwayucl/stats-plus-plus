#!/usr/bin/env bash

set -e

if [ "$#" = "2"]; then
  ./usage-by-faculty -c ${1}-d ${2}-01 > facultyin.csv
  ./miscellc -i miscell/facultyskeleton.mcl -o ${1}-${2}.csv
  rm facultyin.csv
else
  echo "Run with cluster name as argument 1 and YYYY-MM as argument 2"
fi
