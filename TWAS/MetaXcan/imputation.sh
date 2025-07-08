#!/bin/bash

# === Configuration ===
SCRIPT=~/TWAS/summary-gwas-imputation/src/gwas_summary_imputation.py
BY_REGION_FILE=~/TWAS/TWAS_ref/eur_ld.bed.gz
GWAS_FILE=~/TWAS/gwas_preimputation.txt
PANEL_DIR=~/TWAS/TWAS_ref/reference_panel_1000G
OUTPUT_DIR=~/TWAS/imputed_all_chromosomes
WINDOW=100000
PARSIMONY=7
SUB_BATCHES=10

# Max number of parallel jobs
MAX_JOBS=3

# === Create output directory ===
mkdir -p "$OUTPUT_DIR"

# === Main Loop: Chromosomes 1–22 ===
for CHR in {1..22}; do
    echo "=== Starting chromosome $CHR ==="

    CHR_OUTPUT_DIR=$OUTPUT_DIR/chr$CHR
    mkdir -p "$CHR_OUTPUT_DIR"

    JOBS=0  # background job counter

    # Launch all sub-batches with concurrency control
    for SB in $(seq 0 $((SUB_BATCHES - 1))); do
        OUTFILE=$CHR_OUTPUT_DIR/imputed_results_chr${CHR}_subbatch${SB}.csv

        python "$SCRIPT" \
            -by_region_file "$BY_REGION_FILE" \
            -gwas_file "$GWAS_FILE" \
            -parquet_genotype "$PANEL_DIR/chr${CHR}.variants.parquet" \
            -parquet_genotype_metadata "$PANEL_DIR/variant_metadata.parquet" \
            -chromosome "$CHR" \
            -window "$WINDOW" \
            -parsimony "$PARSIMONY" \
            -sub_batches "$SUB_BATCHES" \
            -sub_batch "$SB" \
            --standardise_dosages \
            --cache_variants \
            -output "$OUTFILE" &

        ((JOBS++))

        # If we reach the maximum number of jobs, wait for one to finish
        if [[ $JOBS -ge $MAX_JOBS ]]; then
            wait -n  # wait for at least one background job to finish
            ((JOBS--))
        fi
    done

    # Wait for all background jobs to finish for this chromosome
    wait
    echo "Sub-batches for chromosome $CHR completed."

    # Merge all sub-batch outputs into one file
    FINAL_OUTPUT=$OUTPUT_DIR/imputed_results_chr${CHR}_full.csv
    HEADERS=$(head -n 1 $CHR_OUTPUT_DIR/imputed_results_chr${CHR}_subbatch0.csv)
    echo "$HEADERS" > "$FINAL_OUTPUT"

    for FILE in $CHR_OUTPUT_DIR/imputed_results_chr${CHR}_subbatch*.csv; do
        tail -n +2 "$FILE" >> "$FINAL_OUTPUT"
    done

    echo "Merged chromosome $CHR into $FINAL_OUTPUT"
done

echo "All chromosomes processed and merged!"

