#!/bin/bash

# This file is licensed CC0 by Andrew Harvey <andrew.harvey4@gmail.com>
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

# test for zip dir
if [ -d "01-DATASETS-ZIP" ] ; then
  # extract the shp and csv files out of the zips
  for stats in hts TCS JTW Employment Population Freight travel Spatial Train Bus Ferry ; do
    for f in 01-DATASETS-ZIP/$stats/*.zip ; do
      b=`basename "$f" '.zip'`
      mkdir -p "02-DATASETS-UNZIP/$stats/$b/"
      unzip -n "$f" -d "02-DATASETS-UNZIP/$stats/$b/"
    done
  done
else
  echo "01-DATASETS-ZIP doesn't exist. Run make download first."
  exit 1
fi
