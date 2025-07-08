#!/bin/bash

# Define absolute paths to the files
INPUT="/home/jfernandez/PROJECTE-PT/summary_statistics/build37/japanbiobank.v8.PT/hum0014.v7.PT/BBJ.PT.autosome.csv.gz"
OUTPUT="/home/jfernandez/PROJECTE-PT/summary_statistics/build37/japan.GRCh38.csv.gz"
CHAIN="/home/resources_public/liftOver/hg19ToHg38.over.chain.gz"
LIFTOVER="/home/resources_public/liftOver/liftOver"

# Temporary files
BED_IN="/home/jfernandez/PROJECTE-PT/summary_statistics/build37/temp_input.bed"
BED_OUT="/home/jfernandez/PROJECTE-PT/summary_statistics/build37/temp_lifted.bed"
BED_UNLIFTED="/home/jfernandez/PROJECTE-PT/summary_statistics/build37/temp_unlifted.bed"
DATA_TMP="/home/jfernandez/PROJECTE-PT/summary_statistics/build37/temp_original_data.tsv"
FINAL_TMP="/home/jfernandez/PROJECTE-PT/summary_statistics/build37/temp_final_output.tsv"

echo "Step 1: Generate BED file..."

# Generate BED file
zcat "$INPUT" | awk '
  BEGIN {OFS="\t"}
  NR == 1 {next}  # Skip header
  {
    if (length($4) == 1 && length($5) == 1) {  # Check if REF and ALT are single-base alleles
      chrom = "chr"$2           # Chromosome
      start = $3 - 1            # Start position (convert from 1-based to 0-based)
      end = $3                  # End position
      snp = $1                  # SNP ID
      print chrom, start, end, snp
    }
  }
' > "$BED_IN"

echo "Step 2: Run liftOver..."

# Run liftOver
"$LIFTOVER" "$BED_IN" "$CHAIN" "$BED_OUT" "$BED_UNLIFTED"

echo "Step 3: Process output..."

# Save original input (without LOG10P) as TSV without header
zcat "$INPUT" | awk -F"\t" 'NR==1 {next} {OFS="\t"; print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $12}' > "$DATA_TMP"

# Join by SNP (col 4 in BED, col 1 in DATA_TMP) and reorder columns
# Final output will have columns: CHR, POS, REF, ALT, Frq, Rsq, BETA, SE, P, SNP, N
join -t $'\t' -1 4 -2 1 <(sort -k4,4 "$BED_OUT") <(sort -k1,1 "$DATA_TMP") | \
  awk 'BEGIN{OFS="\t"} {gsub(/^chr/, "", $2); print $2, $4, $7, $8, $9, $10, $11, $12, $13, $1, $14}' > "$FINAL_TMP"

# Add header and compress result
# Add correct header to the beginning of the final file
echo -e "CHR\tPOS\tREF\tALT\tFrq\tRsq\tBETA\tSE\tP\tSNP\tN" > temp_final_with_header.tsv
cat "$FINAL_TMP" >> temp_final_with_header.tsv
mv temp_final_with_header.tsv "$FINAL_TMP"
cat "$FINAL_TMP" | gzip > "$OUTPUT"

# BED files are not deleted and are kept for review

# Actual number of variants processed (excluding header)
total=$(zcat "$INPUT" | tail -n +2 | wc -l)
mapped=$(zcat "$OUTPUT" | tail -n +2 | wc -l)
unmapped=$(cat "$BED_UNLIFTED" | wc -l)

echo "LiftOver complete:"
echo "  Total variants processed: $total"
echo "  Mapped to GRCh38:         $mapped"
echo "  Unmapped (lost):          $unmapped"

