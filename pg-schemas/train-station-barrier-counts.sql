-- To the extent possible under law, the person who associated CC0
-- with this work has waived all copyright and related or neighboring
-- rights to this work.
-- http://creativecommons.org/publicdomain/zero/1.0/

-- Can't do this is a range, as a range won't loop round midnight
CREATE DOMAIN bts.timerange AS text
CHECK (
  VALUE ~ E'^\\d{2}:\\d{2}-\\d{2}:\\d{2}$'
);

CREATE TYPE bts.direction AS ENUM (
  'IN',
  'OUT'
);

CREATE TABLE bts.train_station_barrier_counts (
  line text,
  station text,
  year smallint,
  time bts.timerange,
  direction bts.direction,
  count integer,

  PRIMARY KEY (line, station, year, time, direction)
);
