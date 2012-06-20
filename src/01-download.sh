#!/bin/sh

# This file is licensed CC0 by Andrew Harvey <andrew.harvey4@gmail.com>
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

for stats in hts TCS JTW Employment Population Freight travel Spatial Train Bus Ferry ; do
  echo $stats
  mkdir -p 01-DATASETS-ZIP/$stats
  wget -O - "http://www.bts.nsw.gov.au/Statistics/$stats" 2> /dev/null \
    | grep -o 'href="[^"]*"' \
    | grep 'ArticleDocuments' \
    | sed 's/^href="//' \
    | sed 's/"$//' \
    | sort \
    | uniq \
    | wget -i - --content-disposition --no-clobber --no-http-keep-alive --directory-prefix=01-DATASETS-ZIP/$stats
  # I noticed an issue when not using --no-http-keep-alive it is best not to use it, but I don't know if
  # their server fully supports it.
done
