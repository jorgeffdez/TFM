library(data.table)
library(stringr)

# Read GWAS data
gwas_df <- fread("top_snps/top_snps_cross_ancestry.txt")

# Transform MarkerName from chrN:POS:REF:ALT → chrN_POS_REF_ALT_b38
gwas_df[, id := str_replace_all(MarkerName, ":", "_")]
gwas_df[, id := paste0(id, "_b38")]

# Read reference panel
ref_df <- fread("TWAS/TWAS_ref/reference_panel_1000G/variant_metadata.txt.gz", header = TRUE)

# Filter rows with non-empty rsid
ref_df <- ref_df[!is.na(rsid) & rsid != "NA" & rsid != "."]

# Keep only required columns
ref_df <- ref_df[, .(id, rsid)]

# Merge by id (our transformed SNP)
merged_df <- merge(gwas_df, ref_df, by = "id")

# Reorder columns to place rsid as SNP and clean up
setcolorder(merged_df, c("rsid", setdiff(names(merged_df), c("rsid", "MarkerName", "id"))))
setnames(merged_df,
         old = c("rsid", "Allele1", "Allele2", "Effect", "StdErr", "P.value", "N"),
         new = c("SNP",  "A1",      "A2",      "BETA",  "SE",     "P",       "N"),
         skip_absent = TRUE)

# Drop unnecessary columns
merged_df[, c("id", "MarkerName") := NULL]

# Save cleaned file ready for munge_stats.py
fwrite(merged_df, file = "top_snps_cross_rsid.csv", sep = "\t", quote = FALSE)