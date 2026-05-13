# GFF3-GO-Term-Extractor
A Perl utility for extracting Gene Ontology (GO) annotations from GFF3 annotation files.

## Description
This Perl script identifies for each gene (via its `Parent=` attribute), the transcript with the most `Ontology_term=` entries, making it straightforward to build a gene-level GO annotation table for use in downstream analyses like functional enrichment.

## Usage

```bash
perl extract_gff3_transcript_gos.pl <input_file> <output_file>
```

| Argument | Description |
|---|---|
| `<input_file>` | GFF3-formatted genome annotation file |
| `<output_file>` | Path for the tab-separated output file |

## Requirements
- [Perl 5](https://www.perl.org/)
