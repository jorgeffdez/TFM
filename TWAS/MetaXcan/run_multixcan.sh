#!/bin/bash

# Define base folders
BASE_FOLDER="/home/jfernandez/TWAS"
MASHR_FOLDER="${BASE_FOLDER}/MetaXcan/software"
MASHR_MODELS="/home/resources_public/refpanels/TWAS_ref/ucsc/models/eqtl/mashr"
MASHR_MULTI="/home/resources_public/refpanels/TWAS_ref/ucsc/models"

# Define input files
GWAS_FILE="${BASE_FOLDER}/imputed_final/processed_imputed_gwas.csv.gz"
COV_FILE="${MASHR_MULTI}/gtex_v8_expression_mashr_snp_smultixcan_covariance.txt.gz"
METAXCAN_FOLDER="${BASE_FOLDER}/spredixcan_results/selected_tissues"

# Output path
OUTPUT_FILE="${BASE_FOLDER}/smultixcan_results/PT_smultixcan_selected_tissues.txt"
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Define tissues of interest
tissues=(
  "Artery_Aorta"
  "Artery_Coronary"
  "Artery_Tibial"
  "Liver"
  "Spleen"
  "Whole_Blood"
)

# Create temporary folders for filtered inputs
TEMP_METAXCAN_FOLDER="${BASE_FOLDER}/spredixcan_results/temp_eqtl"
TEMP_DB_FOLDER="${BASE_FOLDER}/models/temp_mashr"
mkdir -p "$TEMP_METAXCAN_FOLDER" "$TEMP_DB_FOLDER"

# Copy only selected tissue result files and db models
for tissue in "${tissues[@]}"; do
  # Copy csv file
  CSV_FILE="${METAXCAN_FOLDER}/PT_${tissue}.csv"
  if [[ -f "$CSV_FILE" ]]; then
    cp "$CSV_FILE" "$TEMP_METAXCAN_FOLDER"
  else
    echo "WARNING: Missing result file: $CSV_FILE"
  fi

  # Copy DB file
  DB_FILE="${MASHR_MODELS}/mashr_${tissue}.db"
  if [[ -f "$DB_FILE" ]]; then
    cp "$DB_FILE" "$TEMP_DB_FOLDER"
  else
    echo "WARNING: Missing DB model: $DB_FILE"
  fi
done

# Run SMulTiXcan
python3 "${MASHR_FOLDER}/SMulTiXcan.py" \
  --models_folder "$TEMP_DB_FOLDER" \
  --models_name_pattern "mashr_(.*).db" \
  --snp_covariance "$COV_FILE" \
  --metaxcan_folder "$TEMP_METAXCAN_FOLDER" \
  --metaxcan_filter "PT_(.*).csv" \
  --metaxcan_file_name_parse_pattern "PT_(.*).csv" \
  --gwas_file "$GWAS_FILE" \
  --snp_column panel_variant_id \
  --effect_allele_column effect_allele \
  --non_effect_allele_column non_effect_allele \
  --zscore_column zscore \
  --keep_non_rsid \
  --model_db_snp_key varID \
  --cutoff_condition_number 30 \
  --verbosity 7 \
  --throw \
  --output "$OUTPUT_FILE"

# Clean up temporary folders (optional)
rm -r "$TEMP_METAXCAN_FOLDER" "$TEMP_DB_FOLDER"

