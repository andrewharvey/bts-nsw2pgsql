#!/usr/bin/env perl

my $xpath_query = $ARGV[0];

# check usage
if (!defined $xpath_query) {
  die "Usage: $0 xpath-query";
}

use XML::XPath;

# load source XML document from stdin
my $xp = XML::XPath->new(ioref => \*STDIN);

# run the xpath query
my $nodeset = $xp->find($xpath_query);

foreach my $node ($nodeset->get_nodelist) {
  # see http://search.cpan.org/perldoc?XML%3A%3AXPath%3A%3ANode%3A%3AAttribute
  print $node->getData, "\n";
}
