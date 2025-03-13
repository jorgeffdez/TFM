# Cargar librerías necesarias
library(data.table)

# Lista de archivos originales
files <- c(
  "./PROJECTE-PT/datasets_cleaned/Non_EVT/CHRIS_cleaned_reordered.csv.gz",
  "./PROJECTE-PT/datasets_cleaned/Non_EVT/GAIT_auto_cleaned.csv.gz",
  "./PROJECTE-PT/datasets_cleaned/Non_EVT/LURIC_auto_cleaned.csv.gz",
  "./PROJECTE-PT/datasets_cleaned/Non_EVT/RETROVE_CASES_auto_cleaned.csv.gz",
  "./PROJECTE-PT/datasets_cleaned/Non_EVT/RETROVE_CONTROLS_auto_cleaned.csv.gz",
  "./PROJECTE-PT/datasets_cleaned/Non_EVT/SHIP_START_auto_cleaned.csv.gz",
  "./PROJECTE-PT/datasets_cleaned/Non_EVT/SHIP_TREND_auto_cleaned.csv.gz",
  "./PROJECTE-PT/datasets_cleaned/Non_EVT/VHS_auto_cleaned.csv.gz",
  "./PROJECTE-PT/datasets_cleaned/Non_EVT/LBC1921_auto_cleaned.csv.gz",
  "./PROJECTE-PT/datasets_cleaned/Non_EVT/LBC1936_auto_cleaned.csv.gz",
  "./PROJECTE-PT/datasets_cleaned/EVT/MARTHA_auto_cleaned.csv.gz"
)

# Iterar sobre cada archivo y filtrar
for (file in files) {
  # Leer archivo
  data <- fread(file)
  
  # Determinar qué columna de frecuencia alélica usar
  if ("AF_coded" %in% colnames(data)) {
    freq_col <- "AF_coded"
  } else if ("EAF" %in% colnames(data)) {
    freq_col <- "EAF"
  } else {
    warning(paste("No se encontró AF_coded ni EAF en:", file))
    next  # Saltar al siguiente archivo
  }
  
  # Filtrar SNPs (mantener solo aquellos con frecuencia entre 0.10 y 0.90)
  data_filtered <- data[(get(freq_col) >= 0.10) & (get(freq_col) <= 0.90)]
  
  # Extraer nombre de cohorte desde el nombre del archivo
  cohort_name <- gsub("_cleaned_reordered.csv.gz|_auto_cleaned.csv.gz", "", basename(file))
  
  # Guardar archivo filtrado
  output_file <- paste0("./PROJECTE-PT/datasets_filtered/", cohort_name, "_filtered.csv.gz")
  fwrite(data_filtered, output_file, compress = "gzip")
  
  print(paste("Archivo filtrado guardado:", output_file))
}
