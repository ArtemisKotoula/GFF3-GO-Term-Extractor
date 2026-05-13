#!/usr/bin/perl

##############################################################################
# Description:
#   Parses a GFF3 annotation file and for each gene (identified by its
#   parent feature), selects the transcript isoform with the greatest number
#   of Gene Ontology (GO) term annotations. It outputs a tab-separated file
#   containing the selected transcript ID and its comma-separated GO terms.
#
# Usage:
#   perl get_ids_with_gos.pl <input_file> <output_file>
#
# Where:
#   <input_file>   : A GFF3-formatted annotation file
#   <output_file>  : Path for the output file
#
# Input format:
#   Standard GFF3 (9-column, tab-separated). The script looks for lines
#   where the feature type (column 3) is "transcript" and the attributes
#   column (column 9) contains an "Ontology_term=" field with GO annotations.
#
# Output format:
#   <transcript_ID>\t<GO:XXXXXXX,GO:XXXXXXX,...>
#   One line per parent gene, sorted alphabetically by parent ID.
###############################################################################

use strict;
use warnings;

##############################################################################
## Argument parsing

my ($input_file, $outfile) = @ARGV;
die "Usage: $0 <input_file> <output_file>\n" unless $input_file && $outfile;

##############################################################################
## GFF3 Parsing

my %best;   # Keyed by parent gene ID; stores the transcript with most GO terms

while (<$fh>) {
    chomp;
    # Skip early if the line is not a transcript feature or has no GO terms
    next unless /\ttranscript\t/ && /Ontology_term=/;

    my @fields     = split(/\t/, $_);
    my $attributes = $fields[8];
    
    # Extract transcript ID and its parent gene ID
    my ($id)     = $attributes =~ /ID=([^;]+)/;
    my ($parent) = $attributes =~ /Parent=([^;]+)/;
    next unless $parent;

    # Extract the GO terms
    my ($go_list) = $attributes =~ /Ontology_term=([^;]+(?:;GO:[0-9]+)*)/;
    next unless defined $go_list;

    my @go_terms = split(/;/, $go_list);
    my $count    = scalar @go_terms;

    # Retain only the transcript with the most GO annotations for each parent
    if (!exists $best{$parent} || $count > scalar @{$best{$parent}->{go}}) {
        $best{$parent} = {
            id => $id,
            go => \@go_terms
        };
    }
}

close $fh;

##############################################################################
## Output

open my $fout, '>', $outfile or die "Could not write '$outfile': $!";

# One line per parent gene: transcript ID followed by comma-separated GO terms
foreach my $parent (sort keys %best) {
    my $id = $best{$parent}->{id};
    my @go = @{$best{$parent}->{go}};
    print $fout $id, "\t", join(",", @go), "\n";
}

close $fout;

print STDOUT "Done. Wrote results to $outfile\n";



