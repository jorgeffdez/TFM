#!/bin/bash

BASE_DIR=~/TWAS/Files_FUSION/fusion_results_sCCA
SUMSTATS="imputed_chromosomes/imputed.cleaned.gwas.allchr.sumstat"
LDREF_PREFIX="/home/resources_public/refpanels/TWAS_ref/LDREF_1000G/1000G.EUR."
OUTDIR=postprocess_cross_tissue_multimodel_chr
mkdir -p "$OUTDIR"

MODELS=("sCCA1" "sCCA2" "sCCA3")

for chr in {1..22}; do
  echo "🔎 Procesando cromosoma $chr..."

  LIST_FILE="${OUTDIR}/chr${chr}_scca_top_files.list"
  > "$LIST_FILE"

  # Generar .top para cada modelo, corregir por modelo (opcional)
  for model in "${MODELS[@]}"; do
    DAT_FILE="${BASE_DIR}/${model}/${model}.chr${chr}.dat"
    TOP_FILE="${OUTDIR}/${model}.chr${chr}.top"

    if [ ! -f "$DAT_FILE" ]; then
      echo "⚠️ No encontrado: $DAT_FILE, saltando..."
      continue
    fi

    GENE_COUNT=$(tail -n +2 "$DAT_FILE" | wc -l)
    TEST_COUNT=$GENE_COUNT
    awk -v n="$TEST_COUNT" 'NR==1 || $NF < 0.05/n' "$DAT_FILE" > "$TOP_FILE"

    if [ "$(wc -l < "$TOP_FILE")" -le 1 ]; then
      echo "⛔ No genes significativos para $model chr$chr, saltando..."
      continue
    fi

    echo "$TOP_FILE" >> "$LIST_FILE"
  done

  # Combinar los .top de los 3 modelos para este cromosoma
  COMBINED_ALL="${OUTDIR}/chr${chr}_all_scca_combined.all"
  COMBINED_TOP="${OUTDIR}/chr${chr}_all_scca_combined.top"

  rm -f "$COMBINED_ALL" "$COMBINED_TOP"
  
  # Copiar header del primer archivo top que exista para el cromosoma
  FIRST_TOP=$(head -n 1 "$LIST_FILE")
  head -n 1 "$FIRST_TOP" > "$COMBINED_ALL"

  # Añadir datos de todos los archivos .top sin header
  while read -r f; do
    tail -n +2 "$f" >> "$COMBINED_ALL"
  done < "$LIST_FILE"

  # Contar total tests válidos (CHR no NA o vacío)
  TOTAL_TESTS=$(awk '($4 != "NA" && $4 != "")' "$COMBINED_ALL" | wc -l)

  # Filtrar con corrección Bonferroni global para este cromosoma
  awk -v n="$TOTAL_TESTS" 'NR==1 || ($4 != "NA" && $4 != "" && $NF < 0.05/n)' "$COMBINED_ALL" > "$COMBINED_TOP"

  echo "🎯 Cromosoma $chr, total tests para Bonferroni: $TOTAL_TESTS"
  echo "🎯 Ejecutando análisis cross-tissue para cromosoma $chr..."

  Rscript ../fusion_twas-master/FUSION.post_process.R \
    --sumstats "$SUMSTATS" \
    --input "$COMBINED_TOP" \
    --out "${OUTDIR}/cross_tissue_chr${chr}.bonferroni" \
    --ref_ld_chr "${LDREF_PREFIX}" \
    --chr "$chr" \
    --plot --locus_win 100000

done

echo "🎉 Análisis cross-tissue por cromosoma (3 modelos juntos) completado."

