#!/bin/bash

# === CONFIGURATION ===
OUTFILE="imputed.cleaned.gwas.allchr.sumstat"

# Remove output file if it exists
rm -f "$OUTFILE"

# Write header from the first file
head -n 1 imputed_chromosomes/imputed.cleaned.gwas.chr1.sumstat.sumstat > "$OUTFILE"

# Append data from each chromosome file (excluding header)
for CHR in {1..22}; do
    tail -n +2 "imputed_chromosomes/imputed.cleaned.gwas.chr${CHR}.sumstat.sumstat" >> "$OUTFILE"
done

echo "✅ Merged all chromosomes into $OUTFILE"
