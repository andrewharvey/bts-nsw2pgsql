#!/usr/bin/perl -w

# This script is licensed CC0 by Andrew Harvey <andrew.harvey4@gmail.com>
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/


use strict;
use Text::CSV;
use Data::Dumper;

# destination database schema + dot, and table
my $schema = "bts.";
my $dst_table = "train_station_barrier_counts";

if (@ARGV != 1) {
  print "Usage: $0 <CityRail_StationBarrierCounts.csv>\n";
}

my $src_csv_full_filename = $ARGV[0];

# open the source csv file for reading
open (my $src_data, '<', "$src_csv_full_filename") or die $!;

my $csv = Text::CSV->new();

my @column_names = $csv->column_names($csv->getline($src_data));

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
  foreach my $key (keys %row) {
    my $value = $row{$key};
    $value =~ s/,//; # remove thousands separator from numbers
    if ($key =~ /^(?<hour_start>\d{2}):(?<minute_start>\d{2}) to (?<hour_end>\d{2}):(?<minute_end>\d{2}) (?<direction>IN|OUT)$/) {
      print "$line\t" .
            "$station\t" .
            "$year\t" .
#            "[" . $+{"hour_start"} . ":" . $+{"minute_start"} . ", " . $+{"hour_end"} . ":" . $+{"minute_end"} . "]" . "\t" .
            $+{"hour_start"} . ":" . $+{"minute_start"} . "-" . $+{"hour_end"} . ":" . $+{"minute_end"} . "\t" .
            $+{"direction"} . "\t" .
            $value .
            "\n";
    }else{
        warn "Unexpected column heading \"$key\"\n";
    }
  }
}

close $src_data or warn $!;
