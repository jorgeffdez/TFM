#!/bin/bash

# === Paths ===
SUMSTATS_DIR="imputed_filtered"
WEIGHTS="../fusion_twas-master/WEIGHTS/GTExv8.EUR.Whole_Blood.pos"
WEIGHTS_DIR="../fusion_twas-master/WEIGHTS"
LDREF_PREFIX="/home/resources_public/refpanels/TWAS_ref/LDREF_1000G/1000G.EUR."
OUTDIR="fusion_tissues"

# === Create output directory ===
mkdir -p "$OUTDIR"

# === Run FUSION for chromosomes 1 to 22 ===
for chr in {1..22}; do
    echo "Running FUSION for Whole Blood - Chromosome $chr..."

    SUMSTATS_FILE="${SUMSTATS_DIR}/chr${chr}.fusion.sumstats.gz"

    if [[ -f "$SUMSTATS_FILE" ]]; then
        Rscript ../fusion_twas-master/FUSION.assoc_test.R \
            --sumstats "$SUMSTATS_FILE" \
            --weights "$WEIGHTS" \
            --weights_dir "$WEIGHTS_DIR" \
            --ref_ld_chr "$LDREF_PREFIX" \
            --chr "$chr" \
            --out "${OUTDIR}/GTEx.EUR.Whole_Blood.chr${chr}.dat"
    else
        echo "Warning: Summary stats not found for chr${chr}, skipping..."
    fi
done
