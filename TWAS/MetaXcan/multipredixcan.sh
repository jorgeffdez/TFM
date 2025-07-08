#!/bin/bash

# Define base folders and mashr models folder
BASE_FOLDER="/home/jfernandez/TWAS/"
MASHR_FOLDER="/home/resources_public/refpanels/TWAS_ref/ucsc/models/eqtl/mashr"

# GWAS file path
GWAS_FILE="${BASE_FOLDER}imputed_final/processed_imputed_gwas.csv.gz"

# Output folder (make sure it exists)
OUTPUT_FOLDER="${BASE_FOLDER}spredixcan_results/selected_tissues"
mkdir -p "${OUTPUT_FOLDER}"

# List of tissues to process
tissues=(
  "Artery_Aorta"
  "Artery_Coronary"
  "Artery_Tibial"
  "Liver"
  "Spleen"
  "Whole_Blood"
)

# Loop over tissues and run SPrediXcan.py for each
for tissue in "${tissues[@]}"
do
  echo "Running SPrediXcan for tissue: $tissue"
  python3 "${BASE_FOLDER}MetaXcan/software/SPrediXcan.py" \
    --gwas_file "$GWAS_FILE" \
    --model_db_path "${MASHR_FOLDER}/mashr_${tissue}.db" \
    --covariance "${MASHR_FOLDER}/mashr_${tissue}.txt.gz" \
    --snp_column panel_variant_id \
    --effect_allele_column effect_allele \
    --non_effect_allele_column non_effect_allele \
    --zscore_column zscore \
    --keep_non_rsid \
    --output_file "${OUTPUT_FOLDER}/PT_${tissue}.csv" \
    --additional_output \
    --model_db_snp_key varID \
    --throw
done

