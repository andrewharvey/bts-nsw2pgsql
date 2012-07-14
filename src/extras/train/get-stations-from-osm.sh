#!/bin/sh

# we need this to prepend to file references where those files are in the same
# directory as this script
cwd=`dirname $0`

# Grab NSW railway stations from FOSM and output a list of the station names
wget -O - 'http://fosm.org/api/0.6/*[railway=station][bbox=140.822754,-37.037640,159.016113,-28.709861]' | $cwd/xpath-values.pl "//tag[@k='name']/@v" | sort > fosm-stations

# Also write out a list of station names in the BTS dataset
cat 02-DATASETS-UNZIP/Train/CityRail_StationBarrierCounts_2004-2011/CityRail_StationBarrierCounts\ 2004-2011.csv | cut -d',' -f2 | sort | uniq > bts-stations
