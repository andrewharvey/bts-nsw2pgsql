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

# load downloaded and unzipped data into the database
load :
