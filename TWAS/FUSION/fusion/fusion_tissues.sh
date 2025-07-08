#!/bin/bash

# Paths
SUMSTATS_DIR="imputed_filtered"
WEIGHTS_DIR="../fusion_twas-master/WEIGHTS"
LDREF_PREFIX="/home/resources_public/refpanels/TWAS_ref/LDREF_1000G/1000G.EUR."
OUTDIR="fusion_tissues"

# Create output directory if it doesn't exist
mkdir -p "$OUTDIR"

# Loop through all .pos files excluding "sCCA" and "nofilter"
for WEIGHTS in "$WEIGHTS_DIR"/*.pos; do
    if [[ "$WEIGHTS" == *sCCA* || "$WEIGHTS" == *nofilter* ]]; then
        continue
    fi

    TISSUE=$(basename "$WEIGHTS" .pos)
    echo "Processing tissue: $TISSUE"

    # Loop through chromosomes 1 to 22
    for chr in {1..22}; do
        echo "  Running FUSION for chr$chr..."

        SUMSTATS_FILE="${SUMSTATS_DIR}/chr${chr}.fusion.sumstats.gz"

        if [[ -f "$SUMSTATS_FILE" ]]; then
            Rscript ../fusion_twas-master/FUSION.assoc_test.R \
                --sumstats "$SUMSTATS_FILE" \
                --weights "$WEIGHTS" \
                --weights_dir "$WEIGHTS_DIR" \
                --ref_ld_chr "${LDREF_PREFIX}" \
                --chr "$chr" \
                --out "${OUTDIR}/${TISSUE}.chr${chr}.dat"
        else
            echo "  Warning: Summary stats for chr${chr} not found, skipping."
        fi
    done
done
