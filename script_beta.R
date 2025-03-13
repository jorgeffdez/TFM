library(data.table)
library(ggplot2)

# Lista de archivos
files <- c("./PROJECTE-PT/datasets_cleaned/Non_EVT/CHRIS_cleaned_reordered.csv.gz", "./PROJECTE-PT/datasets_cleaned/Non_EVT/GAIT_auto_cleaned.csv.gz", "./PROJECTE-PT/datasets_cleaned/Non_EVT/LURIC_auto_cleaned.csv.gz",
           "./PROJECTE-PT/datasets_cleaned/Non_EVT/RETROVE_CASES_auto_cleaned.csv.gz",  "./PROJECTE-PT/datasets_cleaned/Non_EVT/RETROVE_CONTROLS_auto_cleaned.csv.gz",  "./PROJECTE-PT/datasets_cleaned/Non_EVT/SHIP_START_auto_cleaned.csv.gz",
           "./PROJECTE-PT/datasets_cleaned/Non_EVT/SHIP_TREND_auto_cleaned.csv.gz",  "./PROJECTE-PT/datasets_cleaned/Non_EVT/VHS_auto_cleaned.csv.gz",   "./PROJECTE-PT/datasets_cleaned/Non_EVT/LBC1921_auto_cleaned.csv.gz",
           "./PROJECTE-PT/datasets_cleaned/Non_EVT/LBC1936_auto_cleaned.csv.gz",  "./PROJECTE-PT/datasets_cleaned/EVT/MARTHA_auto_cleaned.csv.gz"
           )

# Lista para almacenar los datos filtrados
filtered_data_list <- list()

# Leer y filtrar cada archivo
for (file in files) {
  message("Procesando: ", file)
  
  # Leer datos
  df <- fread(paste0("zcat ", file), sep="\t", header=TRUE)
  
  # Detectar si tiene AF_coded o EAF
  if ("AF_coded" %in% colnames(df)) {
    df <- df[AF_coded >= 0.10 & AF_coded <= 0.90]
  } else if ("EAF" %in% colnames(df)) {
    df <- df[EAF >= 0.10 & EAF <= 0.90]
  }
  
  # Agregar nombre de cohorte
  df[, Cohort := file]
  
  # Guardar datos filtrados
  filtered_data_list[[file]] <- df
}

# Combinar todos los datos filtrados
filtered_data <- rbindlist(filtered_data_list, fill=TRUE)

# Crear boxplot de la distribución de BETA por cohorte
p <- ggplot(filtered_data, aes(x = Cohort, y = BETA)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Distribución de BETA tras filtrado por cohorte",
       x = "Cohorte",
       y = "BETA") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Guardar el plot
ggsave("beta_distribution.png", p)
