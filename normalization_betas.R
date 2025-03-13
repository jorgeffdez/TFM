# Cargar librerías necesarias
library(data.table)

# Directorios de trabajo
filtered_dir <- "./PROJECTE-PT/datasets_filtered/"
normalized_dir <- "./PROJECTE-PT/datasets_normalized/"

# Asegurar que el directorio de salida exista
if (!dir.exists(normalized_dir)) {
  dir.create(normalized_dir)
}

# Obtener archivos filtrados
filtered_files <- list.files(path = filtered_dir, pattern = "*_filtered.csv.gz", full.names = TRUE)
cohorts <- gsub("_filtered.csv.gz", "", basename(filtered_files))

# Cargar el archivo summary_statistics.csv
summary_stats_file <- "./summary_statistics.csv"  
summary_stats_data <- read.csv(summary_stats_file)

# Vectores para SE y Unit
cohort_se_values <- numeric(length(cohorts))
cohort_units <- character(length(cohorts))

# Extraer valores de SE y Unit
for (i in seq_along(cohorts)) {
  cohort_name <- cohorts[i]
  cohort_row <- summary_stats_data[summary_stats_data$Cohort == cohort_name, ]
  
  if (nrow(cohort_row) > 0) {
    se_value <- gsub(".*\\(([^)]+)\\).*", "\\1", cohort_row$Untrans.mean..SD.)
    cohort_se_values[i] <- as.numeric(se_value)
    cohort_units[i] <- as.character(cohort_row$Unit)
  } else {
    warning(paste("No se encontró la cohorte", cohort_name, "en summary_statistics.csv"))
    cohort_se_values[i] <- NA
    cohort_units[i] <- NA
  }
}

# Imprimir valores de Unit para verificar
print("Valores en la columna 'Unit':")
print(cohort_units)

# Procesar cada archivo filtrado
for (i in seq_along(filtered_files)) {
  cohort_data <- fread(filtered_files[i])
  cohort_name <- cohorts[i]
  unit_value <- cohort_units[i]
  se_value <- cohort_se_values[i]
  
  print(paste("Cohorte:", cohort_name))
  print(paste("Unit:", unit_value))
  print(paste("SE antes de ajustes:", se_value))
  
  # Si Unit es "." o está vacío, asignamos SE = 1
  if (is.na(unit_value) || unit_value == "." || unit_value == "") {
    print(paste("Unit no válido para", cohort_name, "- asignando SE = 1"))
    se_value <- 1
  }
  
  print(paste("SE final usado:", se_value))
  
  # Aplicar normalización de BETA
  cohort_data$BETA <- cohort_data$BETA / se_value
  
  # Guardar el archivo normalizado
  output_file <- file.path(normalized_dir, paste0(cohort_name, "_normalized.csv.gz"))
  fwrite(cohort_data, output_file)
  print(paste("Archivo guardado:", output_file))
}
