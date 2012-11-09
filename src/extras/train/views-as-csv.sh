#!/bin/sh

# This file is licensed CC0 by Andrew Harvey <andrew.harvey4@gmail.com>
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

mkdir -p query-extracts/train/station_barrier_counts/

for direction in IN OUT TOTAL; do
  for year in $(seq 2004 2011) ; do
    for time in '02:00-06:00' '06:00-09:30' '09:30-15:00' '15:00-18:30' '18:30-02:00' 'total' ; do
      direction_print=$(echo $direction | tr 'A-Z' 'a-z')
      time_print=$(echo $time | tr -d ':')
      if [ "$direction" != "TOTAL" ] ; then
        direction_sql="direction = '$direction' AND"
      else
        direction_sql=""
      fi
      
      if [ "$time" != "total" ] ; then
        time_sql="time = '$time' AND"
      else
        time_sql=""
      fi
      psql --no-align --field-separator=',' --quiet --tuples-only --command="
        SELECT line, station, sum(count) AS transactions
        FROM bts.train_station_barrier_counts
        WHERE
          $direction_sql
          $time_sql
          year = '$year'
        GROUP BY line, station
        ORDER BY transactions DESC" > query-extracts/train/station_barrier_counts/${direction_print}_${year}_${time_print}.csv;
    done
  done
done
