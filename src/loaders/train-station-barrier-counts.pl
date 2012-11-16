#!/usr/bin/perl -w

# This script is licensed CC0 by Andrew Harvey <andrew.harvey4@gmail.com>
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

# This script will consume the CityRail_StationBarrierCounts.csv file and
# produce a JSON file of the same data in normalised form and to STDOUT
# a PostgreSQL COPY file.

use strict;
use Text::CSV;
use JSON;

# check program usage
if (@ARGV != 1) {
  print "Usage: $0 <CityRail_StationBarrierCounts.csv>\n";
}

my $src_csv_full_filename = $ARGV[0];

# open the source csv file for reading
open (my $src_data, '<', "$src_csv_full_filename") or die $!;

# create the JSON object for producing the JSON output
my $json = JSON->new->allow_nonref;

# set the JSON writer to pretty print
$json = $json->pretty;

# open the JSON file for writing
open (my $json_file, '>', "train-station-barrier-counts.json") or die $!;
open (my $csv_out_file, '>', "train-station-barrier-counts.csv") or die $!;

# use Text::CSV to read the CSV file
my $csv = Text::CSV->new();

my @column_names = $csv->column_names($csv->getline($src_data));

# keeps track of the data to store in the JSON file
my @entries;

print $csv_out_file join (",", qw/line station year timerange direction count/). "\n";

# for each row in the source CSV file
while (my $row_ref = $csv->getline_hr($src_data)) {
  my %row = %{$row_ref};

  # pull out the static columns we want...
  my $line = delete $row{"Line"};
  my $station = delete $row{"Station"};
  my $year = delete $row{"Year"};
  
  my $day_in = delete $row{"24 Hours IN"};
  my $day_out = delete $row{"24 Hours OUT"};

  # ...and throw out the ones we don't...
  delete $row{"Rank"};

  # ...leaving only the dynamic ones left.
  # by looping through each one we get a normalised database
  foreach my $key (keys %row) {
    my $value = $row{$key};
    $value =~ s/,//; # remove thousands separator from numbers
    if ($key =~ /^(?<hour_start>\d{2}):(?<minute_start>\d{2}) to (?<hour_end>\d{2}):(?<minute_end>\d{2}) (?<direction>IN|OUT)$/) { # parse out the column heading to find the exact timespan paramaters
      # write out the PostgreSQL COPY line to STDOUT
      print join ("\t", "$line",
            "$station" ,
            "$year" ,
#            "[" . $+{"hour_start"} . ":" . $+{"minute_start"} . ", " . $+{"hour_end"} . ":" . $+{"minute_end"} . "]" . "\t" . # if using a PostgreSQL range, use this
            $+{"hour_start"} . ":" . $+{"minute_start"} . "-" . $+{"hour_end"} . ":" . $+{"minute_end"} ,
            $+{"direction"} ,
            $value) .
            "\n";

      # add this to the JSON structure
      push @entries, {
          line => $line,
          station => $station,
          year => $year,
          direction => $+{"direction"},
          timerange => $+{"hour_start"} . ":" . $+{"minute_start"} . "-" . $+{"hour_end"} . ":" . $+{"minute_end"},
          count => $value + 0 #+0 to force to number type
        };

      print $csv_out_file join (",", "$line",
            "$station" ,
            "$year" ,
#            "[" . $+{"hour_start"} . ":" . $+{"minute_start"} . ", " . $+{"hour_end"} . ":" . $+{"minute_end"} . "]" . "\t" . # if using a PostgreSQL range, use this
            $+{"hour_start"} . ":" . $+{"minute_start"} . "-" . $+{"hour_end"} . ":" . $+{"minute_end"} ,
            $+{"direction"} ,
            $value) .
            "\n";
    }else{
        warn "Unexpected column heading \"$key\"\n";
    }
  }
}

# write the JOSN structure to disk
print $json_file $json->encode(\@entries);

# close open files
close $src_data or warn $!;
close $json_file or warn $!;
close $csv_out_file or warn $!;
