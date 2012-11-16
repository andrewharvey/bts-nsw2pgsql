# This file is licensed CC0 by Andrew Harvey <andrew.harvey4@gmail.com>
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

all : clean load

# clean up downloaded files
clean-download :
	rm -rf 01-DATASETS-ZIP 02-DATASETS-UNZIP

# download and unzip data from www.bts.nsw.gov.au
download :
	./01-download.sh
	./02-unzip.sh

# clean the database
clean :
	psql -c "DROP SCHEMA bts CASCADE;"
	psql -c "CREATE SCHEMA bts;"
	rm -rf query-extracts

# load downloaded and unzipped data into the database
load :
	psql -f pg-schemas/train-station-barrier-counts.sql
	./src/loaders/train-station-barrier-counts.pl 02-DATASETS-UNZIP/Train/CityRail_StationBarrierCounts_2004-2011/CityRail_StationBarrierCounts\ 2004-2011.csv | psql -c "COPY bts.train_station_barrier_counts FROM STDIN;"
	# now run queries on the loaded data to export it to CSV
	./src/extras/train/views-as-csv.sh

# other misc scripts which don't form part of the main bts-nsw2pgsql scripts, but still may be usefull
extras :
	./src/extras/train/get-stations-from-osm.sh
