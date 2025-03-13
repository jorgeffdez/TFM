# Cargar librerías necesarias
library(ggplot2)
library(data.table)

# Directorio donde están los archivos filtrados
filtered_dir <- "./PROJECTE-PT/datasets_normalized/"

# Buscar archivos filtrados
filtered_files <- list.files(path = filtered_dir, pattern = "*_normalized.csv.gz", full.names = TRUE)

# Lista para almacenar los datos
data_list <- list()

# Cargar cada archivo filtrado y añadir a la lista
for (file in filtered_files) {
  data <- fread(file)
  
  # Verificar si la columna BETA existe
  if ("BETA" %in% colnames(data)) {
    # Extraer nombre de cohorte desde el nombre del archivo
    cohort_name <- gsub("_normalized.csv.gz", "", basename(file))
    
    # Agregar columna de cohorte
    data[, Cohort := cohort_name]
    
    # Guardar en la lista
    data_list[[length(data_list) + 1]] <- data[, .(Cohort, BETA)]
  } else {
    warning(paste("La columna BETA no existe en el archivo:", file))
  }
}

# Unir todos los datasets en uno solo
final_data <- rbindlist(data_list)

# Calcular la mediana de BETA por cohorte
median_data <- final_data[, .(median_BETA = median(BETA, na.rm = TRUE)), by = Cohort]

# Crear el gráfico con medianas
p <- ggplot(median_data, aes(x = Cohort, y = median_BETA, fill = Cohort)) +
  geom_bar(stat = "identity", alpha = 0.7) +  # Barras para mostrar la mediana
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +  # Línea de referencia en 0
  labs(title = "BETA median for Cohort",
       x = "Cohort", y = "BETA median") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotar etiquetas del eje X

# Guardar y mostrar el gráfico
ggsave("median_betas_normalized_cohortes.png", plot = p, width = 10, height = 6, dpi = 150)
print(p)
