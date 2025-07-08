#!/bin/bash

# === Paths (update if needed) ===
SUMSTATS="imputed_chromosomes/imputed.cleaned.gwas.allchr.sumstat"
LDREF_PREFIX="/home/resources_public/refpanels/TWAS_ref/LDREF_1000G/1000G.EUR."
RESULTS_DIR="fusion_results"
OUTDIR="postprocess"

mkdir -p "$OUTDIR"

for chr in {1..22}; do
    echo "Processing chromosome $chr..."

    DAT_FILE="${RESULTS_DIR}/gwas_fusion.chr${chr}.dat"
    TOP_FILE="${OUTDIR}/gwas_fusion.chr${chr}.top"
    OUT_PREFIX="${OUTDIR}/gwas_fusion.chr${chr}.top.analysis"

    # Count genes in this chromosome (exclude header)
    GENE_COUNT=$(tail -n +2 "$DAT_FILE" | wc -l)
    echo "Number of genes in chr${chr}: $GENE_COUNT"

    # Apply Bonferroni correction per chromosome
    awk -v n=$GENE_COUNT 'NR==1 || $NF < 0.05/n' "$DAT_FILE" > "$TOP_FILE"

    if [ $(wc -l < "$TOP_FILE") -le 1 ]; then
      echo "Skipping chromosome $chr — no significant genes found after Bonferroni correction."
      continue
    fi

    # Run FUSION post-processing
    Rscript ../fusion_twas-master/FUSION.post_process.R \
        --sumstats "$SUMSTATS" \
        --input "$TOP_FILE" \
        --out "$OUT_PREFIX" \
        --ref_ld_chr "$LDREF_PREFIX" \
        --chr "$chr" \
        --plot --locus_win 100000
done

