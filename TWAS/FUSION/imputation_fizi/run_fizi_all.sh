#!/bin/bash

# === CONFIGURATION ===
GWAS_FILE="cleaned.gwas.sumstats.gz"
REF_DIR="/home/resources_public/refpanels/TWAS_ref/LDREF_1000G/1000G.EUR"
OUT_PREFIX="imputed.cleaned.gwas.chr"
MAX_PROCS=4  # Number of parallel jobs

# === PROCESSING LOOP ===
for CHR in {1..22}; do
    echo "Processing chromosome $CHR..."

    fizi impute "$GWAS_FILE" "${REF_DIR}.${CHR}" --chr $CHR --out "${OUT_PREFIX}${CHR}.sumstat" &

    # Limit number of concurrent jobs to MAX_PROCS
    while (( $(jobs -r | wc -l) >= MAX_PROCS )); do
        sleep 5
    done
done

# Wait for all background jobs to finish
wait
echo "Imputation complete for all chromosomes!"
