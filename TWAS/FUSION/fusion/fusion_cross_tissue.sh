#!/bin/bash

# === Config paths ===
SUMSTATS="imputed_chromosomes/imputed.cleaned.gwas.allchr.sumstat"
WEIGHTS_DIR="../fusion_twas-master/WEIGHTS"
LDREF_PREFIX="/home/resources_public/refpanels/TWAS_ref/LDREF_1000G/1000G.EUR."
SCCA_MODELS=("sCCA1" "sCCA2" "sCCA3")
BASE_OUTDIR="fusion_results_sCCA"

mkdir -p "$BASE_OUTDIR"

for MODEL in "${SCCA_MODELS[@]}"; do
  POS_FILE="${WEIGHTS_DIR}/${MODEL}.pos"
  OUTDIR="${BASE_OUTDIR}/${MODEL}"
  mkdir -p "$OUTDIR"

  if [[ ! -s "$POS_FILE" ]]; then
    echo "❌ Missing .pos file for $MODEL at $POS_FILE"
    continue
  else
    echo "📄 Found .pos file for $MODEL"
  fi

  echo "🚀 Starting analysis for model: $MODEL"

  for chr in {1..22}; do
    echo "  📍 Processing chr$chr..."

    Rscript ../fusion_twas-master/FUSION.assoc_test.R \
      --sumstats "$SUMSTATS" \
      --weights "$POS_FILE" \
      --weights_dir "$WEIGHTS_DIR" \
      --ref_ld_chr "$LDREF_PREFIX" \
      --chr "$chr" \
      --out "${OUTDIR}/${MODEL}.chr${chr}.dat"
  done

  echo "✅ Finished model: $MODEL"
  echo
done

echo "🏁 All sCCA models processed."

